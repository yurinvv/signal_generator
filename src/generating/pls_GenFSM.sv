`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Module Name: pls_GenFSM
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: The generator finitive state machine
//////////////////////////////////////////////////////////////////////////////////
module pls_GenFSM#(
	parameter DATA_SIZE = 32
	)(
	input aclk,
	input aresetn,	
	
	input start,
	input stop,
	
	IRegs.in regs0,
	IRegs.in regs1,
	input group_select,
	
	ICalculator.out add_calc,
	
	IAxiStream.Master maxis_signal
	);
	
	`include "parameters.svh";
	
	logic isFirstSegmentIteration;
	logic isSegmentEnd;
	logic isSignalEnd;
	logic isRepeatEnd;
	
	logic[31:0] cycleCounter;
	logic[7:0] segment;
	logic[DATA_SIZE - 1:0] pointCounter;
	logic internal_gs; //internal group select,
	
	
	logic[DATA_SIZE - 1:0] startLine;
	logic[DATA_SIZE - 1:0] increment;
	logic[DATA_SIZE - 1:0] pointCountInt;
	logic[DATA_SIZE - 1:0] lineCount;
	logic[DATA_SIZE - 1:0] repetitions;
	
	logic[DATA_SIZE - 1:0] currentValue;
	
	
	/************************
	*   FSM logic
	*************************/

	typedef enum { 
		IDLE,
		VALIDATE,
		GET,
		INCREMENT_REQUEST,
		INCREMENT_RESPONCE,
		SEND,
		SIGNAL_STATE,
		XXX
		} state_e;
		
	state_e state, next;	

	always_ff @(posedge aclk)
		if (!aresetn) state <= IDLE;
		else state <= next;

	always_comb begin
		next = state;
		
		case (state)
		IDLE:
			if (start)
				next = VALIDATE;
			
		VALIDATE:
			next = GET;
						
		GET:
			if (isFirstSegmentIteration) 
				next = SEND;
			else
				next = INCREMENT_REQUEST;
				
		INCREMENT_REQUEST:
			next = INCREMENT_RESPONCE;
			
		INCREMENT_RESPONCE:  
			if (!add_calc.start & !add_calc.busy) 
				next = SEND;
				
		SEND: 
			if (maxis_signal.tready & maxis_signal.tvalid)
				next = SIGNAL_STATE;
				
		SIGNAL_STATE:
			if (isRepeatEnd | stop)
				next = IDLE;
			else if (isSignalEnd)
				next = VALIDATE;
			else if (isSegmentEnd)
				next = GET;
			else
				next = INCREMENT_REQUEST;
			
		default: next = XXX;
		endcase
	end
	
	/************************
	*   Segment select
	*************************/	
	
	always_ff@(posedge aclk)
		if(!aresetn)
			pointCounter <= 0;
		else
			case (state)
			IDLE, VALIDATE:
				pointCounter <= 0;
				
			SIGNAL_STATE:
				if (isSegmentEnd)
					pointCounter <= 0;
				else
					pointCounter <= pointCounter + 1;
					
			default: pointCounter <= pointCounter;
			endcase	
	
	
	always_ff@(posedge aclk)
		if(!aresetn)
			segment <= 0;
		else
			case (state)
			IDLE, VALIDATE:
				segment <= 0;
				
			SIGNAL_STATE:
				if (isSegmentEnd)
					segment <= segment + 1;
					
			default: segment <= segment;
			endcase
	
	assign isSegmentEnd = pointCounter == pointCountInt - 1;
	
	/******************************
	* Signal end
	******************************/
	
	assign isSignalEnd = isSegmentEnd & segment == lineCount - 1;
	assign isRepeatEnd = isSignalEnd & cycleCounter == repetitions - 1;
	
	always_ff@(posedge aclk)
		if(!aresetn)
			cycleCounter <= 0;
		else
			case (state)
			IDLE :
				cycleCounter <= 0;
				
			SIGNAL_STATE:
				if (isSignalEnd)
					cycleCounter <= cycleCounter + 1;
					
			default: cycleCounter <= cycleCounter;
			endcase

	/******************************
	* First Segment
	******************************/
	
	assign isFirstSegmentIteration = pointCounter == 0;
			
		
	/************************
	*   VALIDATE
	*   Get registers group
	*************************/
	always_ff@(posedge aclk)
		if (!aresetn) internal_gs <= 0;
		else
			case (state)
			VALIDATE:
				internal_gs <= group_select;
				
			default: internal_gs <= internal_gs;
			endcase
			
						
	/******************************
	*  INCREMENT
	*******************************/
		always_ff@(posedge aclk)
		if(!aresetn) currentValue <= 0;
		else
            case(state)
                GET:
					currentValue <= startLine;
					
                INCREMENT_RESPONCE:
					currentValue <= add_calc.result;
					
                default: currentValue <= currentValue;
            endcase	

	
		always_ff@(posedge aclk)
		if(!aresetn)
			begin
			add_calc.a <= 0;
			add_calc.b <= 0;
			add_calc.start <= 0;
			end
		else
            case(state)
                INCREMENT_REQUEST:
                    begin
                    add_calc.start <= 1;
                    add_calc.a <= currentValue;
                    add_calc.b <= increment;
                    end
					
                default:
                    begin
                    add_calc.start <= 0;
                    add_calc.a <= add_calc.a;
                    add_calc.b <= add_calc.b;
                    end
            endcase	
	
	/******************************
	*  SEND
	*******************************/
		assign maxis_signal.tlast = maxis_signal.tvalid;
		
		logic valid_cnt;
	
		always_ff@(posedge aclk)
		if (!aresetn)
			begin
			maxis_signal.tvalid <= 0;
			maxis_signal.tdata <= 0;
			valid_cnt <= 0;
			end
		else
			case (state)
			SEND:
				begin
				if (valid_cnt)
					maxis_signal.tvalid <= 1;
				else if (maxis_signal.tready)
					maxis_signal.tvalid <= 0;
				else 
					maxis_signal.tvalid  <= maxis_signal.tvalid ;
				
				valid_cnt <= 0;
				
				maxis_signal.tdata <= currentValue;
				end
				
			default:  
				begin
				maxis_signal.tvalid <= 0;
				maxis_signal.tdata <= 0;
				valid_cnt <= 1;
				end
			endcase
	//************************
	// SELECT PARAMS
	//************************
	always_comb
		begin
		lineCount   = internal_gs? regs1.linenmb    : regs0.linenmb    ;
		repetitions = internal_gs? regs1.repeatcycle: regs0.repeatcycle;
		case (segment)
		0:
			begin
			startLine   = internal_gs? regs1.linea [0]  : regs0.linea [0]  ;
			increment   = internal_gs? regs1.offset[0]  : regs0.offset[0]  ;
			pointCountInt  = internal_gs? regs1.linet_int [0]  : regs0.linet_int [0]  ;

			end
		1:
			begin
			startLine   = internal_gs? regs1.linea [1]  : regs0.linea [1]  ;
			increment   = internal_gs? regs1.offset[1]  : regs0.offset[1]  ;
			pointCountInt  = internal_gs? regs1.linet_int [1]  : regs0.linet_int [1]  ;
			end
		2:
			begin
			startLine   = internal_gs? regs1.linea [2]  : regs0.linea [2]  ;
			increment   = internal_gs? regs1.offset[2]  : regs0.offset[2]  ;
			pointCountInt  = internal_gs? regs1.linet_int [2]  : regs0.linet_int [2]  ;
			end
		3:
			begin
			startLine   = internal_gs? regs1.linea [3]  : regs0.linea [3]  ;
			increment   = internal_gs? regs1.offset[3]  : regs0.offset[3]  ;
			pointCountInt  = internal_gs? regs1.linet_int [3]  : regs0.linet_int [3]  ;
			end
		4:
			begin
			startLine   = internal_gs? regs1.linea [4]  : regs0.linea [4]  ;
			increment   = internal_gs? regs1.offset[4]  : regs0.offset[4]  ;
			pointCountInt  = internal_gs? regs1.linet_int [4]  : regs0.linet_int [4]  ;
			end
		5:
			begin
			startLine   = internal_gs? regs1.linea [5]  : regs0.linea [5]  ;
			increment   = internal_gs? regs1.offset[5]  : regs0.offset[5]  ;
			pointCountInt  = internal_gs? regs1.linet_int [5]  : regs0.linet_int [5]  ;
			end
		6:
			begin
			startLine   = internal_gs? regs1.linea [6]  : regs0.linea [6]  ;
			increment   = internal_gs? regs1.offset[6]  : regs0.offset[6]  ;
			pointCountInt  = internal_gs? regs1.linet_int [6]  : regs0.linet_int [6]  ;
			end
		7:
			begin
			startLine   = internal_gs? regs1.linea [7]  : regs0.linea [7]  ;
			increment   = internal_gs? regs1.offset[7]  : regs0.offset[7]  ;
			pointCountInt  = internal_gs? regs1.linet_int [7]  : regs0.linet_int [7]  ;
			end
		8:
			begin
			startLine   = internal_gs? regs1.linea [8]  : regs0.linea [8]  ;
			increment   = internal_gs? regs1.offset[8]  : regs0.offset[8]  ;
			pointCountInt  = internal_gs? regs1.linet_int [8]  : regs0.linet_int [8]  ;
			end
		endcase
		end
		
endmodule