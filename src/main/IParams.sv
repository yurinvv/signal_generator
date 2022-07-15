`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Module Name: IParams
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: Interface between the parametrs and the configurator
//////////////////////////////////////////////////////////////////////////////////
interface IParams #(	
	parameter PARAM_SIZE = 32,
	parameter POINTS = 9
	)();
	
	typedef logic [PARAM_SIZE - 1 : 0] linea_t [POINTS - 1 : 0];
	typedef logic [PARAM_SIZE - 1 : 0] linet_t [POINTS - 1 : 0];
	typedef logic [PARAM_SIZE - 1 : 0] linet_int_t [POINTS - 1 : 0];
	typedef logic [PARAM_SIZE - 1 : 0] linenmb_t;
	typedef logic [PARAM_SIZE - 1 : 0] repeatcycle_t;
	
	linea_t       linea;
	linet_t       linet;
	linet_int_t linet_int;
	linenmb_t     linenmb;
	repeatcycle_t repeatcycle;
	
	modport out (
		output linea,
		output linet,
		output linet_int,
		output linenmb,
		output repeatcycle
	);
	
	modport in (
		input linea,
		input linet,
		input linet_int,
		input linenmb,
		input repeatcycle
	);

endinterface // IAxiStream