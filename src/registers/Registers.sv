`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Module Name: Registers
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: the register group
//////////////////////////////////////////////////////////////////////////////////
module Registers#(
	parameter ADRR_SIZE = 6,
	parameter DATA_SIZE = 32
)(
	input aclk,
	input aresetn,
	IModBus.slave  sConfig,
	IRegs.out regs
);
	
	`include "parameters.svh";
	
	// Writing
	logic writeEnable;
	
	assign writeEnable = sConfig.awvalid & sConfig.dwvalid & sConfig.wready;
	
	assign sConfig.wready = 1;
	
	always_ff@(posedge aclk)
		if (writeEnable)
			case (sConfig.waddr)
			LINEA_OFFSET  : regs.linea[0]    <= sConfig.wdata;
			           1  : regs.linea[1]    <= sConfig.wdata;
			           2  : regs.linea[2]    <= sConfig.wdata;
			           3  : regs.linea[3]    <= sConfig.wdata;
			           4  : regs.linea[4]    <= sConfig.wdata;
			           5  : regs.linea[5]    <= sConfig.wdata;
			           6  : regs.linea[6]    <= sConfig.wdata;
			           7  : regs.linea[7]    <= sConfig.wdata;
			           8  : regs.linea[8]    <= sConfig.wdata;
			LINET_OFFSET  : regs.linet[0]    <= sConfig.wdata;
			          10  : regs.linet[1]    <= sConfig.wdata;
			          11  : regs.linet[2]    <= sConfig.wdata;
			          12  : regs.linet[3]    <= sConfig.wdata;
			          13  : regs.linet[4]    <= sConfig.wdata;
			          14  : regs.linet[5]    <= sConfig.wdata;
			          15  : regs.linet[6]    <= sConfig.wdata;
			          16  : regs.linet[7]    <= sConfig.wdata;
			          17  : regs.linet[8]    <= sConfig.wdata;
			LINENMB_OFFSET: regs.linenmb     <= sConfig.wdata;
			REPEATCYCLE   : regs.repeatcycle <= sConfig.wdata;
			INC_OFFSET    : regs.offset[0]   <= sConfig.wdata;
			          21  : regs.offset[1]   <= sConfig.wdata;
			          22  : regs.offset[2]   <= sConfig.wdata;
			          23  : regs.offset[3]   <= sConfig.wdata;
			          24  : regs.offset[4]   <= sConfig.wdata;
			          25  : regs.offset[5]   <= sConfig.wdata;
			          26  : regs.offset[6]   <= sConfig.wdata;
			          27  : regs.offset[7]   <= sConfig.wdata;
			          28  : regs.offset[8]   <= sConfig.wdata;
		    LINET_F_OFFSET: regs.linet_int[0]   <= sConfig.wdata;
		                30: regs.linet_int[1]   <= sConfig.wdata;
		                31: regs.linet_int[2]   <= sConfig.wdata;
		                32: regs.linet_int[3]   <= sConfig.wdata;
		                33: regs.linet_int[4]   <= sConfig.wdata;
		                34: regs.linet_int[5]   <= sConfig.wdata;
		                35: regs.linet_int[6]   <= sConfig.wdata;
		                36: regs.linet_int[7]   <= sConfig.wdata;
		                37: regs.linet_int[8]   <= sConfig.wdata;
			endcase

endmodule