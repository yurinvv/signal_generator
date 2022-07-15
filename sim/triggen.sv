`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Program Name: triggen
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: genrator od trigger signals
//////////////////////////////////////////////////////////////////////////////////

program triggen#(
	parameter WAIT_BEFORE_START = 5000,
	parameter TSTART = 1000,
	parameter TSTOP	 = 10000,
	parameter STAPT_PULSE = 100,
	parameter STOP_PULSE = 100,
	parameter REPEAT = 5
)(
	output bit start,
	output bit stop
);
	
	initial
		begin
		#1;
		start = 0;
		stop = 0;
		#WAIT_BEFORE_START;
		repeat(REPEAT)
			begin
			start = 1;
			#STAPT_PULSE;
			start = 0;
			#(TSTOP - STAPT_PULSE);
			stop = 1;
			#STOP_PULSE;
			stop = 0;
			#(TSTART - STOP_PULSE);
			end
		end
endprogram

