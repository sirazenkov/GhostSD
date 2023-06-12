
// file: clk_gen.v
// 
// (c) Copyright 2008 - 2013 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
//----------------------------------------------------------------------------
// User entered comments
//----------------------------------------------------------------------------
// None
//
//----------------------------------------------------------------------------
//  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
//   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
//----------------------------------------------------------------------------
// _otp_clk__175.00000______0.000______50.0______189.056____233.292
// sd_fast_clk__50.00000______0.000______50.0______229.608____233.292
// sd_slow_clk___8.20313______0.000______50.0______325.337____233.292
//
//----------------------------------------------------------------------------
// Input Clock   Freq (MHz)    Input Jitter (UI)
//----------------------------------------------------------------------------
// __primary_________125.000____________0.010

`timescale 1ps/1ps

module clk_gen_clk_wiz 

 (// Clock in ports
  // Clock out ports
  output        otp_clk,
  output        sd_fast_clk,
  output        sd_slow_clk,
  // Status and control signals
  input         reset,
  input         iclk
 );
  // Input buffering
  //------------------------------------
wire iclk_clk_gen;
wire clk_in2_clk_gen;
  IBUF clkin1_ibufg
   (.O (iclk_clk_gen),
    .I (iclk));




  // Clocking PRIMITIVE
  //------------------------------------

  // Instantiation of the MMCM PRIMITIVE
  //    * Unused inputs are tied off
  //    * Unused outputs are labeled unused

  wire        otp_clk_clk_gen;
  wire        sd_fast_clk_clk_gen;
  wire        sd_slow_clk_clk_gen;
  wire        clk_out4_clk_gen;
  wire        clk_out5_clk_gen;
  wire        clk_out6_clk_gen;
  wire        clk_out7_clk_gen;

  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        locked_int;
  wire        clkfbout_clk_gen;
  wire        clkfbout_buf_clk_gen;
  wire        clkfboutb_unused;
   wire clkout3_unused;
   wire clkout4_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;
  wire        reset_high;

  PLLE2_ADV
  #(.BANDWIDTH            ("OPTIMIZED"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (5),
    .CLKFBOUT_MULT        (42),
    .CLKFBOUT_PHASE       (0.000),
    .CLKOUT0_DIVIDE       (6),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT1_DIVIDE       (21),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKOUT2_DIVIDE       (128),
    .CLKOUT2_PHASE        (0.000),
    .CLKOUT2_DUTY_CYCLE   (0.500),
    .CLKIN1_PERIOD        (8.000))
  plle2_adv_inst
    // Output clocks
   (
    .CLKFBOUT            (clkfbout_clk_gen),
    .CLKOUT0             (otp_clk_clk_gen),
    .CLKOUT1             (sd_fast_clk_clk_gen),
    .CLKOUT2             (sd_slow_clk_clk_gen),
    .CLKOUT3             (clkout3_unused),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
     // Input clock control
    .CLKFBIN             (clkfbout_buf_clk_gen),
    .CLKIN1              (iclk_clk_gen),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    // Other control and status signals
    .LOCKED              (locked_int),
    .PWRDWN              (1'b0),
    .RST                 (reset_high));
  assign reset_high = reset; 

// Clock Monitor clock assigning
//--------------------------------------
 // Output buffering
  //-----------------------------------

  BUFG clkf_buf
   (.O (clkfbout_buf_clk_gen),
    .I (clkfbout_clk_gen));






  BUFG clkout1_buf
   (.O   (otp_clk),
    .I   (otp_clk_clk_gen));


  BUFG clkout2_buf
   (.O   (sd_fast_clk),
    .I   (sd_fast_clk_clk_gen));

  BUFG clkout3_buf
   (.O   (sd_slow_clk),
    .I   (sd_slow_clk_clk_gen));



endmodule
