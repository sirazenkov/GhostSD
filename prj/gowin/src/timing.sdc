//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.07 Education
//Created Time: 2023-04-07 00:13:03
create_clock -name iclk -period 37.037 -waveform {0 18.518} [get_ports {iclk}]
create_clock -name clk_sd -period 41.667 -waveform {0 20} [get_pins {clock_divider_inst/DCS_inst/dcs_inst/CLKOUT}]
