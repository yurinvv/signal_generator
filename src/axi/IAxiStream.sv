`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Module Name: IAxiStream
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: AXI-Stream interface
//////////////////////////////////////////////////////////////////////////////////
interface IAxiStream #(	
	parameter DATA_SIZE = 32,
	parameter ID_SIZE = 4
	)(
	//input logic aclk,
	//input logic areset_n
	);
	
	//--------------------------------
	logic tvalid;
	logic tready;
	logic tlast;
	logic[DATA_SIZE - 1 : 0] tdata;
	logic[ID_SIZE - 1 : 0] tid;
	
	//--------------------------------
	modport Master(
		output tvalid,
		input tready,
		output tlast,
		output tdata,
		output tid
	);
	
	modport Slave(
		input tvalid,
		output tready,
		input tlast,
		input tdata,
		input tid
	);

endinterface // IAxiStream