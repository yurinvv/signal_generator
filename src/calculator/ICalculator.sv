`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Module Name: ICalculator
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: Interfaces for calculator services which controlls some float-point alu
//////////////////////////////////////////////////////////////////////////////////
interface ICalculator #(	
	parameter DATA_SIZE = 32
	)();
	
	logic [DATA_SIZE - 1 : 0] a;
	logic [DATA_SIZE - 1 : 0] b;
	logic [DATA_SIZE - 1 : 0] result;
	logic start;
	logic busy;
	//logic exception;
	
	modport in (
		//output exception,
		input  a,
		input  b,
		output result,
		input  start,
		output busy
	);
	
	modport out (
		//output exception,
		output a,
		output b,
		input  result,
		output start,
		input  busy
	);
	
endinterface // IAxiStream