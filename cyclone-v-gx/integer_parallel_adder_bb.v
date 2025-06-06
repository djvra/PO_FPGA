// megafunction wizard: %PARALLEL_ADD%VBB%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: parallel_add 

// ============================================================
// File Name: integer_parallel_adder.v
// Megafunction Name(s):
// 			parallel_add
//
// Simulation Library Files(s):
// 			altera_mf
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 23.1std.1 Build 993 05/14/2024 SC Lite Edition
// ************************************************************

//Copyright (C) 2024  Intel Corporation. All rights reserved.
//Your use of Intel Corporation's design tools, logic functions 
//and other software and tools, and any partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Intel Program License 
//Subscription Agreement, the Intel Quartus Prime License Agreement,
//the Intel FPGA IP License Agreement, or other applicable license
//agreement, including, without limitation, that your use is for
//the sole purpose of programming logic devices manufactured by
//Intel and sold by Intel or its authorized distributors.  Please
//refer to the applicable agreement for further details, at
//https://fpgasoftware.intel.com/eula.

module integer_parallel_adder (
	data0x,
	data10x,
	data11x,
	data1x,
	data2x,
	data3x,
	data4x,
	data5x,
	data6x,
	data7x,
	data8x,
	data9x,
	result);

	input	[63:0]  data0x;
	input	[63:0]  data10x;
	input	[63:0]  data11x;
	input	[63:0]  data1x;
	input	[63:0]  data2x;
	input	[63:0]  data3x;
	input	[63:0]  data4x;
	input	[63:0]  data5x;
	input	[63:0]  data6x;
	input	[63:0]  data7x;
	input	[63:0]  data8x;
	input	[63:0]  data9x;
	output	[67:0]  result;

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone V"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: CONSTANT: MSW_SUBTRACT STRING "NO"
// Retrieval info: CONSTANT: PIPELINE NUMERIC "0"
// Retrieval info: CONSTANT: REPRESENTATION STRING "SIGNED"
// Retrieval info: CONSTANT: RESULT_ALIGNMENT STRING "LSB"
// Retrieval info: CONSTANT: SHIFT NUMERIC "0"
// Retrieval info: CONSTANT: SIZE NUMERIC "12"
// Retrieval info: CONSTANT: WIDTH NUMERIC "64"
// Retrieval info: CONSTANT: WIDTHR NUMERIC "68"
// Retrieval info: USED_PORT: data0x 0 0 64 0 INPUT NODEFVAL "data0x[63..0]"
// Retrieval info: USED_PORT: data10x 0 0 64 0 INPUT NODEFVAL "data10x[63..0]"
// Retrieval info: USED_PORT: data11x 0 0 64 0 INPUT NODEFVAL "data11x[63..0]"
// Retrieval info: USED_PORT: data1x 0 0 64 0 INPUT NODEFVAL "data1x[63..0]"
// Retrieval info: USED_PORT: data2x 0 0 64 0 INPUT NODEFVAL "data2x[63..0]"
// Retrieval info: USED_PORT: data3x 0 0 64 0 INPUT NODEFVAL "data3x[63..0]"
// Retrieval info: USED_PORT: data4x 0 0 64 0 INPUT NODEFVAL "data4x[63..0]"
// Retrieval info: USED_PORT: data5x 0 0 64 0 INPUT NODEFVAL "data5x[63..0]"
// Retrieval info: USED_PORT: data6x 0 0 64 0 INPUT NODEFVAL "data6x[63..0]"
// Retrieval info: USED_PORT: data7x 0 0 64 0 INPUT NODEFVAL "data7x[63..0]"
// Retrieval info: USED_PORT: data8x 0 0 64 0 INPUT NODEFVAL "data8x[63..0]"
// Retrieval info: USED_PORT: data9x 0 0 64 0 INPUT NODEFVAL "data9x[63..0]"
// Retrieval info: USED_PORT: result 0 0 68 0 OUTPUT NODEFVAL "result[67..0]"
// Retrieval info: CONNECT: @data 0 0 64 0 data0x 0 0 64 0
// Retrieval info: CONNECT: @data 0 0 64 640 data10x 0 0 64 0
// Retrieval info: CONNECT: @data 0 0 64 704 data11x 0 0 64 0
// Retrieval info: CONNECT: @data 0 0 64 64 data1x 0 0 64 0
// Retrieval info: CONNECT: @data 0 0 64 128 data2x 0 0 64 0
// Retrieval info: CONNECT: @data 0 0 64 192 data3x 0 0 64 0
// Retrieval info: CONNECT: @data 0 0 64 256 data4x 0 0 64 0
// Retrieval info: CONNECT: @data 0 0 64 320 data5x 0 0 64 0
// Retrieval info: CONNECT: @data 0 0 64 384 data6x 0 0 64 0
// Retrieval info: CONNECT: @data 0 0 64 448 data7x 0 0 64 0
// Retrieval info: CONNECT: @data 0 0 64 512 data8x 0 0 64 0
// Retrieval info: CONNECT: @data 0 0 64 576 data9x 0 0 64 0
// Retrieval info: CONNECT: result 0 0 68 0 @result 0 0 68 0
// Retrieval info: GEN_FILE: TYPE_NORMAL integer_parallel_adder.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL integer_parallel_adder.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL integer_parallel_adder.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL integer_parallel_adder.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL integer_parallel_adder_inst.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL integer_parallel_adder_bb.v TRUE
// Retrieval info: LIB_FILE: altera_mf
