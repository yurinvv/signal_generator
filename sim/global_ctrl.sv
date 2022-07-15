`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Program Name: global_ctrl
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: clocking and reset
//////////////////////////////////////////////////////////////////////////////////

program global_ctrl#(
	parameter IDLE = 1000,
	parameter HALFPERIOD = 5
)(
	output bit aclk,
	output bit aresetn
);
	initial
		begin
		aresetn = 0;
		#IDLE;
		aresetn = 1;
		end
	
	initial
		forever
			begin
			aclk = 1;
			#HALFPERIOD;
			aclk = 0;
			#HALFPERIOD;
			end
endprogram