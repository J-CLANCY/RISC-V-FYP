// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Mon Jan 21 16:18:22 2019
// Host        : hp running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {c:/Users/user/Desktop/Everyhting/College/4th
//               Year/FYP/RISCV_Top/RISC-V.srcs/sources_1/ip/data_memory/data_memory_stub.v}
// Design      : data_memory
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2018.2" *)
module data_memory(clka, rsta, ena, wea, addra, dina, douta, rsta_busy)
/* synthesis syn_black_box black_box_pad_pin="clka,rsta,ena,wea[0:0],addra[9:0],dina[31:0],douta[31:0],rsta_busy" */;
  input clka;
  input rsta;
  input ena;
  input [0:0]wea;
  input [9:0]addra;
  input [31:0]dina;
  output [31:0]douta;
  output rsta_busy;
endmodule
