`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Module Name: pls_Generator
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: combination of generator finite state machine and calculate service for some float-point addition operation
//////////////////////////////////////////////////////////////////////////////////
module pls_Generator#(
	parameter DATA_SIZE = 32
	)(
	input aclk,
	input aresetn,	
	
	input start,
	input stop,
	
	IRegs.in regs0,
	IRegs.in regs1,
	input group_select,
	
	// Floating-Point adder
	IAxiStream.Master add_a,
	IAxiStream.Master add_b,
	IAxiStream.Slave  add_result,
	
	IAxiStream.Master maxis_signal
);
	
	// Instance of ICalculator interface
	ICalculator#(DATA_SIZE) adder();
	
	
	// Service for addition of float-points digits
	CalcService addExecutor (aclk, aresetn, adder, add_a, add_b, add_result);
	
	// FSM
	pls_GenFSM#(DATA_SIZE)
	genFSM(
		aclk,
		aresetn,	
		start,
		stop,
		regs0,
		regs1,
		group_select,
		adder, // to CalcService addExecutor
		maxis_signal
	);
	
endmodule