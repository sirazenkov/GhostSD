-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
-- Date        : Sat Jun 10 19:57:47 2023
-- Host        : DESKTOP-0KDN2IG running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               g:/CS/MyProjects/GhostSD/prj/xilinx/ghost_sd.gen/sources_1/ip/clk_gen/clk_gen_stub.vhdl
-- Design      : clk_gen
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_gen is
  Port ( 
    otp_clk : out STD_LOGIC;
    sd_fast_clk : out STD_LOGIC;
    reset : in STD_LOGIC;
    iclk : in STD_LOGIC
  );

end clk_gen;

architecture stub of clk_gen is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "otp_clk,sd_fast_clk,reset,iclk";
begin
end;
