`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Module Name: ICalculator
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: combination of configurator finite state machine and increment calculate service
//////////////////////////////////////////////////////////////////////////////////
module pls_Configurator#(
	parameter ADRR_SIZE = 6,
	parameter DATA_SIZE = 32
	)(
	input aclk,
	input aresetn,
	
	input update,
	
	IParams.in s_params,
	
	// Register groups

	IModBus.master reg_group1,
	IModBus.master reg_group2,
	output group_select,
	
	// Floating-Point divider
	IAxiStream.Master div_a,
	IAxiStream.Master div_b,
	IAxiStream.Slave  div_result,
	
	// Floating-Point subtractor
	IAxiStream.Master sub_a,
	IAxiStream.Master sub_b,
	IAxiStream.Slave  sub_result
	
);
	ICalculator#(DATA_SIZE)   io_data();
	logic [DATA_SIZE - 1 : 0] io_data_lines;

	pls_IncrementCalculator#(DATA_SIZE)
	incrementGetter(
		aclk,
		aresetn,
		io_data,
		io_data_lines,
		div_a,
		div_b,
		div_result,
		sub_a,
		sub_b,
		sub_result
	);
	
	
	pls_ConfigFSM#(DATA_SIZE)
	pls_ConfigFSM_inst(
		aclk,
		aresetn,
		update,
		s_params,
		io_data,
		io_data_lines,
		reg_group1,
		reg_group2,
		group_select
	);
	
endmodule