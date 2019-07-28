// megafunction wizard: %LPM_MUX%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: LPM_MUX 

// ============================================================
// File Name: delta_t_clk_mux.v
// Megafunction Name(s):
// 			LPM_MUX
//
// Simulation Library Files(s):
// 			lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 18.0.0 Build 614 04/24/2018 SJ Standard Edition
// ************************************************************


//Copyright (C) 2018  Intel Corporation. All rights reserved.
//Your use of Intel Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Intel Program License 
//Subscription Agreement, the Intel Quartus Prime License Agreement,
//the Intel FPGA IP License Agreement, or other applicable license
//agreement, including, without limitation, that your use is for
//the sole purpose of programming logic devices manufactured by
//Intel and sold by Intel or its authorized distributors.  Please
//refer to the applicable agreement for further details.


//lpm_mux DEVICE_FAMILY="Cyclone IV E" LPM_SIZE=2 LPM_WIDTH=1 LPM_WIDTHS=1 data result sel
//VERSION_BEGIN 18.0 cbx_lpm_mux 2018:04:24:18:04:18:SJ cbx_mgl 2018:04:24:18:08:49:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463


//synthesis_resources = lut 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  delta_t_clk_mux_mux
	( 
	data,
	result,
	sel) /* synthesis synthesis_clearbox=1 */;
	input   [1:0]  data;
	output   [0:0]  result;
	input   [0:0]  sel;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   [1:0]  data;
	tri0   [0:0]  sel;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [0:0]  result_node;
	wire  [0:0]  sel_node;
	wire  [1:0]  w_data4w;

	assign
		result = result_node,
		result_node = {((sel_node & w_data4w[1]) | ((~ sel_node) & w_data4w[0]))},
		sel_node = {sel[0]},
		w_data4w = {data[1:0]};
endmodule //delta_t_clk_mux_mux
//VALID FILE


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module delta_t_clk_mux (
	data0,
	data1,
	sel,
	result)/* synthesis synthesis_clearbox = 1 */;

	input	  data0;
	input	  data1;
	input	  sel;
	output	  result;

	wire [0:0] sub_wire5;
	wire  sub_wire2 = data1;
	wire  sub_wire0 = data0;
	wire [1:0] sub_wire1 = {sub_wire2, sub_wire0};
	wire  sub_wire3 = sel;
	wire  sub_wire4 = sub_wire3;
	wire [0:0] sub_wire6 = sub_wire5[0:0];
	wire  result = sub_wire6;

	delta_t_clk_mux_mux	delta_t_clk_mux_mux_component (
				.data (sub_wire1),
				.sel (sub_wire4),
				.result (sub_wire5));

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "1"
// Retrieval info: PRIVATE: new_diagram STRING "1"
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: CONSTANT: LPM_SIZE NUMERIC "2"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_MUX"
// Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "1"
// Retrieval info: CONSTANT: LPM_WIDTHS NUMERIC "1"
// Retrieval info: USED_PORT: data0 0 0 0 0 INPUT NODEFVAL "data0"
// Retrieval info: USED_PORT: data1 0 0 0 0 INPUT NODEFVAL "data1"
// Retrieval info: USED_PORT: result 0 0 0 0 OUTPUT NODEFVAL "result"
// Retrieval info: USED_PORT: sel 0 0 0 0 INPUT NODEFVAL "sel"
// Retrieval info: CONNECT: @data 0 0 1 0 data0 0 0 0 0
// Retrieval info: CONNECT: @data 0 0 1 1 data1 0 0 0 0
// Retrieval info: CONNECT: @sel 0 0 1 0 sel 0 0 0 0
// Retrieval info: CONNECT: result 0 0 0 0 @result 0 0 1 0
// Retrieval info: GEN_FILE: TYPE_NORMAL delta_t_clk_mux.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL delta_t_clk_mux.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL delta_t_clk_mux.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL delta_t_clk_mux.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL delta_t_clk_mux_inst.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL delta_t_clk_mux_bb.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL delta_t_clk_mux_syn.v TRUE
// Retrieval info: LIB_FILE: lpm
