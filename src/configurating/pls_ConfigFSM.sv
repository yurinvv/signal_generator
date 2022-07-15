`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Module Name: ICalculator
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: The configurator finitive state machine
//////////////////////////////////////////////////////////////////////////////////
module pls_ConfigFSM#(
	parameter DATA_SIZE = 32
)(
	input aclk,
	input aresetn,
	
	input update,
	
	IParams.in s_params,
	
	ICalculator.out m_calc,
	output logic [DATA_SIZE - 1 : 0] m_lines,
	
	IModBus.master m_reg0,
	IModBus.master m_reg1,
	
	output group_select
);
	
	`include "parameters.svh";
	
	logic [7:0] offset;
	logic [DATA_SIZE - 1 : 0] nextData;
	logic [DATA_SIZE - 1 : 0] nextA;
	logic [DATA_SIZE - 1 : 0] nextB;
	logic [DATA_SIZE - 1 : 0] nextLines;
	
	logic cs;

	logic wready;
	logic dwvalid;
	assign dwvalid = m_reg1.dwvalid | m_reg0.dwvalid;
	assign wready = cs ? m_reg1.wready : m_reg0.wready;
	/*******************************
	*   FSM
	*******************************/

	typedef enum { 
		IDLE,
		UPDATE,
		CALC_REQ,
		CALC_RESP,
		ADDITIONAL,
		DONE,
		XXX
		} state_e;
	
	state_e state, next;
	
	always_ff @(posedge aclk)
		if (!aresetn) state <= IDLE;
		else state <= next;
		
	always_comb begin
		next = state;
		case (state)
		IDLE:      
			if (update)
				next = UPDATE;
				
		UPDATE:
			if (wready & offset >= REPEATCYCLE) 
				begin
					if (offset >= END_OFFSET)
						next = ADDITIONAL;//next = DONE;
					else if (dwvalid)
						next = CALC_REQ;
				end
				
		CALC_REQ:
			if (m_calc.start)
				next = CALC_RESP;
				
		CALC_RESP:
			if (!m_calc.busy & !m_calc.start)
				next = UPDATE;
				
		ADDITIONAL:
			if (offset == LINET_F_END)
				next = DONE;
			else 
				next = UPDATE;
		DONE:
			if (!update)
				next = IDLE;
				
		default: next = XXX;
		endcase
	end
			
	/****************************************
	*   Update process
	****************************************/
	always_comb
		case(offset)
		LINEA_OFFSET  : nextData = s_params.linea[0];
		             1: nextData = s_params.linea[1];
		             2: nextData = s_params.linea[2];
		             3: nextData = s_params.linea[3];
		             4: nextData = s_params.linea[4];
		             5: nextData = s_params.linea[5];
		             6: nextData = s_params.linea[6];
		             7: nextData = s_params.linea[7];
		             8: nextData = s_params.linea[8];
		LINET_OFFSET  : nextData = s_params.linet[0];
		            10: nextData = s_params.linet[1];
		            11: nextData = s_params.linet[2];
		            12: nextData = s_params.linet[3];
		            13: nextData = s_params.linet[4];
		            14: nextData = s_params.linet[5];
		            15: nextData = s_params.linet[6];
		            16: nextData = s_params.linet[7];
		            17: nextData = s_params.linet[8];
		LINENMB_OFFSET: nextData = s_params.linenmb;
		REPEATCYCLE   : nextData = s_params.repeatcycle;
		//-----------------------------------------
		LINET_F_OFFSET: nextData = s_params.linet_int[0];
		            30: nextData = s_params.linet_int[1];
		            31: nextData = s_params.linet_int[2];
		            32: nextData = s_params.linet_int[3];
		            33: nextData = s_params.linet_int[4];
		            34: nextData = s_params.linet_int[5];
		            35: nextData = s_params.linet_int[6];
		            36: nextData = s_params.linet_int[7];
		            37: nextData = s_params.linet_int[8];
		default       : nextData = m_calc.result;
		endcase
	
	//ModBus Master implementation
	always_ff@(posedge aclk)
		if(!aresetn)
			begin
			m_reg0.waddr   <= 0;
			m_reg0.wdata   <= 0;
			m_reg0.awvalid <= 0;
			m_reg0.dwvalid <= 0;
			
			m_reg1.waddr   <= 0;
			m_reg1.wdata   <= 0;
			m_reg1.awvalid <= 0;
			m_reg1.dwvalid <= 0;
			end
		else
            case(state)
                UPDATE:
                    begin
                    if (cs)
                        begin
                        m_reg1.wdata   <= nextData;
                        m_reg1.waddr   <= offset;
                        m_reg1.awvalid <= !m_reg1.awvalid;
                        m_reg1.dwvalid <= !m_reg1.dwvalid;
                        end
                    else
                        begin
                        m_reg0.wdata   <= nextData;
                        m_reg0.waddr   <= offset;
                        m_reg0.awvalid <= !m_reg0.awvalid;
                        m_reg0.dwvalid <= !m_reg0.dwvalid;
                        end
                    end
                default:
                    begin
                    m_reg0.wdata   <= m_reg0.wdata;
                    m_reg0.waddr   <= m_reg0.waddr;
                    m_reg0.awvalid <= 0;
                    m_reg0.dwvalid <= 0;
                    
                    m_reg1.waddr   <= m_reg1.waddr ;
                    m_reg1.wdata   <= m_reg1.wdata;
                    m_reg1.awvalid <= 0;
                    m_reg1.dwvalid <= 0;
                    end
            endcase
	
	//New address
	always_ff@(posedge aclk)
		if(!aresetn) 
			offset <= 0;
		else
			case (state)
			IDLE :
				offset <= 0;
			default:
				offset <= (wready & dwvalid) ? offset + 1 : offset;
			endcase

	/****************************************
	*   Calculate process
	****************************************/
	
	always_comb
		case(offset)
		INC_OFFSET:
				begin
				nextA <= s_params.linea[1];
				nextB <= s_params.linea[0];
				nextLines <= s_params.linet[0];
				end
			21:
				begin
				nextA <= s_params.linea[2];
				nextB <= s_params.linea[1];
				nextLines <= s_params.linet[1];
				end
			22:
				begin
				nextA <= s_params.linea[3];
				nextB <= s_params.linea[2];
				nextLines <= s_params.linet[2];
				end
			23:
				begin
				nextA <= s_params.linea[4];
				nextB <= s_params.linea[3];
				nextLines <= s_params.linet[3];
				end 
			24:
				begin
				nextA <= s_params.linea[5];
				nextB <= s_params.linea[4];
				nextLines <= s_params.linet[4];
				end
			25:
				begin
				nextA <= s_params.linea[6];
				nextB <= s_params.linea[5];
				nextLines <= s_params.linet[5];
				end 
			26:
				begin
				nextA <= s_params.linea[7];
				nextB <= s_params.linea[6];
				nextLines <= s_params.linet[6];
				end 
			27:
				begin
				nextA <= s_params.linea[8];
				nextB <= s_params.linea[7];
				nextLines <= s_params.linet[7];
				end 
		default:
				begin
				nextA <= s_params.linea[0];
				nextB <= s_params.linea[8];
				nextLines <= s_params.linet[8];
				end
		endcase
	

	always_ff@(posedge aclk)
		if(!aresetn)
			begin
			m_calc.a <= 0;
			m_calc.b <= 0;
			m_lines  <= 0;
			m_calc.start <= 0;
			end
		else
            case(state)
                CALC_REQ:
                    begin
                    m_calc.start <= m_calc.busy ? m_calc.start : 1;
                    m_calc.a <= nextA;
                    m_calc.b <= nextB;
                    m_lines  <= nextLines;
                    end
                default:
                    begin
                    m_calc.start <= 0;
                    m_calc.a <= m_calc.a;
                    m_calc.b <= m_calc.b;
                    m_lines  <= m_lines;
                    end
            endcase	
		
	/****************************************
	*   Chip select
	****************************************/
		always_ff@(posedge aclk)
			if(!aresetn) cs <= 0;
			else
				case(state)
					DONE   : if (!update) cs <= !cs;
					default: cs <= cs;
				endcase	
		
	/****************************************
	*   Group select
	****************************************/
	assign group_select = !cs;
	
endmodule