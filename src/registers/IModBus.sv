`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Module Name: IModBus
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: Interface between the register groups and the configurator
//////////////////////////////////////////////////////////////////////////////////
interface IModBus#(
	parameter ADRR_SIZE = 4,
	parameter DATA_SIZE = 32
	)();
	
	logic [ADRR_SIZE - 1 : 0] waddr;
	logic [DATA_SIZE - 1 : 0] wdata;
	logic awvalid;
	logic dwvalid;
	logic wready;
	
	logic [ADRR_SIZE - 1 : 0] raddr;
	logic [DATA_SIZE - 1 : 0] rdata;
	logic arvalid;
	logic drvalid;
	logic rready;
	
	modport slave (
		input  waddr,
		input  wdata,
		input  awvalid,
		input  dwvalid,
		output wready,
		
		input  raddr,
		output rdata,
		input  arvalid,
		output drvalid,
		input  rready		
	);
	
	modport master (
		output  waddr,
		output  wdata,
		output  awvalid,
		output  dwvalid,
		input   wready,
		
		output  raddr,
		input   rdata,
		output  arvalid,
		input   drvalid,
		output  rready	
	);

endinterface


