`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Module Name: CalcService
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: The calculator service sends the values to some float-point operator via axis buses and receives the result of the calculation via another axis bus
//////////////////////////////////////////////////////////////////////////////////
module CalcService(
	input aclk,
	input aresetn,
	
	ICalculator.in   ioData,
	
	// Floating-Point operator
	IAxiStream.Master a,
	IAxiStream.Master b,
	IAxiStream.Slave  result
);
	/************************
	*   FSM
	*************************/
	
	typedef enum { 
		IDLE,
		REQUEST,
		RESPONSE,
		DONE,
		XXX
		} state_e;
	
	state_e state, next;
	
	always_ff @(posedge aclk)
		if (!aresetn) state <= IDLE;
		else state <= next;
		
	always_comb begin
		next = state;
		case (state)
		IDLE:     if (ioData.start)        next = REQUEST;
		REQUEST:                           next = RESPONSE;
		RESPONSE: if (result.tvalid)       next = DONE;		
		DONE:     if (!ioData.start)       next = IDLE;
		default:  next = XXX;
		endcase
	end
	/*
	*   Busy flag process
	*/
	
	always_ff @(posedge aclk)
		if(!aresetn) ioData.busy <= 0;
		else
			case(state)
			IDLE: if (ioData.start) ioData.busy <= 1;
			DONE: ioData.busy <= 0;
			default: ioData.busy <= ioData.busy;
			endcase		

	/**
	*    Execution
	*/
	
	// AXIS operation signals control
	always_ff@(posedge aclk)
		if(!aresetn)
			begin
			a.tvalid <= 0;
			a.tlast  <= 0;
			a.tid    <= 0;	
			b.tvalid <= 0;
			b.tlast  <= 0;
			b.tid    <= 0;	
			end
		else
			case(state)
			REQUEST:
				begin
				a.tvalid <= 1;
				a.tlast  <= 1;
				b.tvalid <= 1;
				b.tlast  <= 1;
				end		
			default:
				begin
				a.tvalid <= 0;
				a.tlast  <= 0;
				b.tvalid <= 0;
				b.tlast  <= 0;	
				end
			endcase
			
	// AXIS TREADY signal control
	//assign result.tready = 0; 
	
	always_ff@(posedge aclk)
		if(!aresetn) result.tready <= 0;
		else
			case(state)	
			REQUEST, RESPONSE: result.tready <= 1;
			default:  result.tready <= 0;
			endcase
		
	// Data signals control
	always_ff@(posedge aclk)
		if(!aresetn)
			begin
			a.tdata <= 0;
			b.tdata <= 0;
			ioData.result <= 0;
			end
		else
			case(state)
			REQUEST:
				begin
				a.tdata  <= ioData.a;
				b.tdata  <= ioData.b;
				end		
			RESPONSE: if (result.tvalid) ioData.result <= result.tdata;
			default:
				begin
				a.tdata       <= a.tdata;
				b.tdata       <= b.tdata ;
				ioData.result <= ioData.result;
				end
			endcase
			
endmodule