`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Module Name: ICalculator
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: Service for calculating increment values for each signal segment
//////////////////////////////////////////////////////////////////////////////////

// result = ( a - b ) / lines
module pls_IncrementCalculator#(
	parameter DATA_SIZE = 32
)(
	input aclk,
	input aresetn,
	
	ICalculator.in io_data,
	input [DATA_SIZE - 1 : 0] io_data_lines,
	
	// Floating-Point divider
	IAxiStream.Master div_a,
	IAxiStream.Master div_b,
	IAxiStream.Slave  div_result,
	
	// Floating-Point subtractor
	IAxiStream.Master sub_a,
	IAxiStream.Master sub_b,
	IAxiStream.Slave  sub_result
);
	
	logic [DATA_SIZE - 1 : 0] subResult;
	
	ICalculator#(DATA_SIZE) divider();
	ICalculator#(DATA_SIZE) subtractor();
	
	CalcService divideExecutor   (aclk, aresetn, divider,    div_a, div_b, div_result);
	CalcService subtractExecutor (aclk, aresetn, subtractor, sub_a, sub_b, sub_result);
	
	/*******************************
	*   FSM
	*******************************/

	typedef enum { 
		IDLE,
		SUBTR_REQ,
		SUBTR_RESP,
		DIV_REQ,
		DIV_RESP,
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
		IDLE:       if (io_data.start)    next = SUBTR_REQ;
		SUBTR_REQ:  if (subtractor.busy)  next = SUBTR_RESP;
		SUBTR_RESP: if (!subtractor.busy) next = DIV_REQ; 
		DIV_REQ:    if (divider.busy)     next = DIV_RESP;
		DIV_RESP:   if (!divider.busy)    next = DONE;
		DONE:       if (!io_data.start)   next = IDLE;
		default: next = XXX;
		endcase
	end

	
	/****************************************
	*   Busy flag process
	****************************************/
	always_ff@(posedge aclk)
		if(!aresetn) io_data.busy <= 0;
		else
			case(state)
			IDLE, DONE: io_data.busy <= 0;
			default: io_data.busy <= 1;
			endcase
			
	/****************************************
	*    Subtraction
	****************************************/
	// result = a - b
	
	// Set a and b
	always_ff@(posedge aclk)
		if(!aresetn)
			begin
			subtractor.a <= 0;
			subtractor.b <= 0;
			end
		else
			case(state)
			IDLE:
				if (io_data.start)
				begin
				subtractor.a <= io_data.a;
				subtractor.b <= io_data.b;
				end
			default:
				begin
				subtractor.a <= subtractor.a;
				subtractor.b <= subtractor.b;
				end
			endcase
	
	// Request a subtraction
	always_ff@(posedge aclk)
		if(!aresetn) subtractor.start <= 0;
		else
			case(state)
			SUBTR_REQ: subtractor.start <= 1;	
			default:   subtractor.start <= 0;
			endcase			
			
	// Get result of a subtraction a and b
	always_ff@(posedge aclk)
		if(!aresetn) subResult <= 0;
		else
			case(state)
			SUBTR_RESP:
				if (!subtractor.busy) subResult <= subtractor.result;
			default: subResult <= subResult;
			endcase

	/****************************************
	*    Division
	****************************************/
	// result = a / b

	// Set a
	always_ff@(posedge aclk)
		if(!aresetn) divider.a <= 0;
		else
			case(state)
			DIV_REQ: divider.a <= subResult;
			default: divider.a <= divider.a;
			endcase		
	
	// Set b
	always_ff@(posedge aclk)
		if(!aresetn) divider.b <= 0;
		else
			case(state)
			IDLE: if (io_data.start) divider.b <= io_data_lines;
			default: divider.b <= divider.b;
			endcase	

	// Request a division
	always_ff@(posedge aclk)
		if(!aresetn) divider.start <= 0;
		else
			case(state)
			DIV_REQ: divider.start <= 1;	
			default: divider.start <= 0;
			endcase	


	// Get result of a division
	always_ff@(posedge aclk)
		if(!aresetn) io_data.result <= 0;
		else
			case(state)
			DIV_RESP: 
				if (!divider.busy)
					io_data.result <= divider.result;
					
			default: io_data.result <= io_data.result;
			endcase			
endmodule