// megafunction wizard: %LPM_DIVIDE%VBB%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: LPM_DIVIDE 

// ============================================================
// File Name: divider.v
// Megafunction Name(s):
// 			LPM_DIVIDE
//
// Simulation Library Files(s):
// 			lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 13.1.0 Build 162 10/23/2013 SJ Web Edition
// ************************************************************

//Copyright (C) 1991-2013 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.

module divider (
	clock,
	denom,
	numer,
	quotient,
	remain);

	input	  clock;
	input	[4:0]  denom;
	input	[10:0]  numer;
	output	[10:0]  quotient;
	output	[4:0]  remain;

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: PRIVATE: PRIVATE_LPM_REMAINDERPOSITIVE STRING "FALSE"
// Retrieval info: PRIVATE: PRIVATE_MAXIMIZE_SPEED NUMERIC "6"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: USING_PIPELINE NUMERIC "1"
// Retrieval info: PRIVATE: VERSION_NUMBER NUMERIC "2"
// Retrieval info: PRIVATE: new_diagram STRING "1"
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: CONSTANT: LPM_DREPRESENTATION STRING "UNSIGNED"
// Retrieval info: CONSTANT: LPM_HINT STRING "MAXIMIZE_SPEED=6,LPM_REMAINDERPOSITIVE=FALSE"
// Retrieval info: CONSTANT: LPM_NREPRESENTATION STRING "SIGNED"
// Retrieval info: CONSTANT: LPM_PIPELINE NUMERIC "1"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_DIVIDE"
// Retrieval info: CONSTANT: LPM_WIDTHD NUMERIC "5"
// Retrieval info: CONSTANT: LPM_WIDTHN NUMERIC "11"
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL "clock"
// Retrieval info: USED_PORT: denom 0 0 5 0 INPUT NODEFVAL "denom[4..0]"
// Retrieval info: USED_PORT: numer 0 0 11 0 INPUT NODEFVAL "numer[10..0]"
// Retrieval info: USED_PORT: quotient 0 0 11 0 OUTPUT NODEFVAL "quotient[10..0]"
// Retrieval info: USED_PORT: remain 0 0 5 0 OUTPUT NODEFVAL "remain[4..0]"
// Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
// Retrieval info: CONNECT: @denom 0 0 5 0 denom 0 0 5 0
// Retrieval info: CONNECT: @numer 0 0 11 0 numer 0 0 11 0
// Retrieval info: CONNECT: quotient 0 0 11 0 @quotient 0 0 11 0
// Retrieval info: CONNECT: remain 0 0 5 0 @remain 0 0 5 0
// Retrieval info: GEN_FILE: TYPE_NORMAL divider.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL divider.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL divider.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL divider.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL divider_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL divider_bb.v TRUE
// Retrieval info: LIB_FILE: lpm
