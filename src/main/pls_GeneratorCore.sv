`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Module Name: pls_GeneratorCore
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: Combination of configurator, generator and two groups of registers.
//////////////////////////////////////////////////////////////////////////////////
module pls_GeneratorCore#(	
	parameter ADRR_SIZE = 6,
	parameter DATA_SIZE = 32
	)(
	input aclk,
	input aresetn,
	input update,
	input start,
	input stop,
	
	IParams.in         params,
	IAxiStream.Master  maxis_signal,
	
	// Floating-Point divider
	IAxiStream.Master div_a,
	IAxiStream.Master div_b,
	IAxiStream.Slave  div_result,
	
	// Floating-Point subtractor
	IAxiStream.Master sub_a,
	IAxiStream.Master sub_b,
	IAxiStream.Slave  sub_result,
	
	// Floating-Point subtractor
	IAxiStream.Master add_a,
	IAxiStream.Master add_b,
	IAxiStream.Slave  add_result
);

	IModBus#(ADRR_SIZE, DATA_SIZE)  configBus1();
	IModBus#(ADRR_SIZE, DATA_SIZE)  configBus2();
	
	IRegs genRegs0();
	IRegs genRegs1();
	
	logic group_select;
	
	
	/***********************************************
	*
	* The instance of the Configuration Controller module
	*
	***********************************************/
	pls_Configurator#(ADRR_SIZE, DATA_SIZE)
	configurator (
		aclk,
		aresetn,
		update,
		params,
		// Register groups
		configBus1,
		configBus2,
		group_select,
		// Floating-Point divider
		div_a,
		div_b,
		div_result,
		// Floating-Point subtractor
		sub_a,
		sub_b,
		sub_result
	);
	
	/***********************************************
	*
	* The first instance of the Registers module
	* The first group of registers
	*
	***********************************************/	
	Registers#(ADRR_SIZE, DATA_SIZE)
	regGroup1(
		aclk,
		aresetn,
		configBus1,
		genRegs0
	);
	
	/***********************************************
	*
	* The second instance of the Registers module
	* The second group of registers
	*
	***********************************************/	
	Registers#(ADRR_SIZE, DATA_SIZE)
	regGroup2(
		aclk,
		aresetn,
		configBus2,
		genRegs1
	);
	
	/***********************************************
	*
	* The instance of the Generator Controller module
	*
	***********************************************/
	pls_Generator#(DATA_SIZE)
	generator (
		aclk,
		aresetn,
		// Triggers		
		start,
		stop,
		// Register groups
		genRegs0,
		genRegs1,
		group_select,
		// Floating-Point adder
		add_a,
		add_b,
		add_result,
		// Samples
		maxis_signal
	);
	
endmodule