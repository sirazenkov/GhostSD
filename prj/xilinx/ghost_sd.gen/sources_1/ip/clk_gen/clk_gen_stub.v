// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Sun May  7 03:04:24 2023
// Host        : DESKTOP-0KDN2IG running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top clk_gen -prefix
//               clk_gen_ clk_gen_stub.v
// Design      : clk_gen
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_gen(otp_clk, sd_fast_clk, reset, iclk)
/* synthesis syn_black_box black_box_pad_pin="otp_clk,sd_fast_clk,reset,iclk" */;
  output otp_clk;
  output sd_fast_clk;
  input reset;
  input iclk;
endmodule
