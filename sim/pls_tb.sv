`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Module Name: pls_tb
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: testbench
//////////////////////////////////////////////////////////////////////////////////
module pls_tb;

	parameter ADRR_SIZE = 6;
	parameter DATA_SIZE = 32;
	parameter POINTS = 9;

	// Global signals
	bit aclk;
	bit aresetn;
	bit update;
	bit start;
	bit stop;

	// Interface for input parameters
	IParams#(DATA_SIZE, POINTS) params_inf();

	// Interface for ouput signal data
	IAxiStream#(DATA_SIZE, 4)   signal_inf();

	// AXIS for divider
	IAxiStream#(DATA_SIZE, 4)   div_a_inf();
	IAxiStream#(DATA_SIZE, 4)   div_b_inf();
	IAxiStream#(DATA_SIZE, 4)   div_r_inf();

	// AXIS for subtractor
	IAxiStream#(DATA_SIZE, 4)   sub_a_inf();
	IAxiStream#(DATA_SIZE, 4)   sub_b_inf();
	IAxiStream#(DATA_SIZE, 4)   sub_r_inf();

	// AXIS for adder
	IAxiStream#(DATA_SIZE, 4)   add_a_inf();
	IAxiStream#(DATA_SIZE, 4)   add_b_inf();
	IAxiStream#(DATA_SIZE, 4)   add_r_inf();

	// Global signals
	global_ctrl#(1000, 5) global_inst(aclk, aresetn);	

	// Trigger generator
	triggen#(.WAIT_BEFORE_START(15000), .TSTOP(300000), .REPEAT(1))
	triggen_inst(start, stop);

	// Loader
	loader#(.PATH("E:/MVA/piecewise_linear_signal_generator/sim/pcoder/sim_params.txt")) 
	loader_inst(params_inf, update);

	// Printer
	printer#(32, "E:/MVA/piecewise_linear_signal_generator/sim/sample_decoder/signal.txt") 
	printer_inst(aclk, aresetn, signal_inf, stop);

	// Design under test
	pls_GeneratorCore#(ADRR_SIZE, DATA_SIZE)
	DUT	(
		aclk,
		aresetn,
		update,
		start,
		stop,
		params_inf,
		signal_inf,
		div_a_inf,
		div_b_inf,
		div_r_inf,
		sub_a_inf,
		sub_b_inf,
		sub_r_inf,
		add_a_inf,
		add_b_inf,
		add_r_inf
	);	

/**
*
*	FLOAT OPERATORS
*
*/

	axis_adder adder_inst(
		aclk,
		aresetn,
		add_a_inf,
		add_b_inf,
		add_r_inf
	);	

	axis_divide axis_divide_inst(
		aclk,
		aresetn,
		div_a_inf,
		div_b_inf,
		div_r_inf
	);		

	axis_subtr subtractor_inst(
		aclk,
		aresetn,
		sub_a_inf,
		sub_b_inf,
		sub_r_inf
	);	

	
/*
	//-------------------------
	// Xilinx cores
	//

	// Adder
	add_float_operator adder_inst (
		//.aclk                 (aclk),
		//.aresetn              (aresetn),        
		.s_axis_a_tvalid      (add_a_inf.tvalid),    
		//.s_axis_a_tready      (add_a_inf.tready),     
		.s_axis_a_tdata       (add_a_inf.tdata),      
		                     
		.s_axis_b_tvalid      (add_b_inf.tvalid),     
		//.s_axis_b_tready      (add_b_inf.tready),     
		.s_axis_b_tdata       (add_b_inf.tdata),  
		
		.m_axis_result_tvalid (add_r_inf.tvalid),
		//.m_axis_result_tready (add_r_inf.tready),
		.m_axis_result_tdata  (add_r_inf.tdata) 
	);

	// Divider
	divide_float_operator divider_inst (
		//.aclk                 (aclk),
		//.aresetn              (aresetn),  
		.s_axis_a_tvalid      (div_a_inf.tvalid),            
		//.s_axis_a_tready      (div_a_inf.tready),            
		.s_axis_a_tdata       (div_a_inf.tdata),              
                              
		.s_axis_b_tvalid      (div_b_inf.tvalid),            
		//.s_axis_b_tready      (div_b_inf.tready),            
		.s_axis_b_tdata       (div_b_inf.tdata),   
		                      
		.m_axis_result_tvalid (div_r_inf.tvalid),  
		//.m_axis_result_tready (div_r_inf.tready),  
		.m_axis_result_tdata  (div_r_inf.tdata)     
	);

	// Subtractor
	subtract_float_operator subtractor_inst (
		//.aclk                (aclk),    
		//.aresetn             (aresetn),  
		.s_axis_a_tvalid      (sub_a_inf.tvalid),                      
		//.s_axis_a_tready      (sub_a_inf.tready),            
		.s_axis_a_tdata       (sub_a_inf.tdata),    
		                      
		.s_axis_b_tvalid      (sub_b_inf.tvalid),                       
		//.s_axis_b_tready      (sub_b_inf.tready),                   
		.s_axis_b_tdata       (sub_b_inf.tdata),   
		
		.m_axis_result_tvalid (sub_r_inf.tvalid),  
		//.m_axis_result_tready (sub_r_inf.tready),  
		.m_axis_result_tdata  (sub_r_inf.tdata)     
	);	
*/
endmodule