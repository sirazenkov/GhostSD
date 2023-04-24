//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.07 Education
//Created Time: 2023-04-25 03:08:23
create_clock -name iclk -period 37.037 -waveform {0 18.518} [get_ports {iclk}]
create_clock -name oclk_sd_d -period 20 -waveform {0 10} [get_pins {clock_divider_inst/DCS_inst/dcs_inst/CLKOUT}]
set_false_path -from [get_regs {rst_s0}] -to [all_clocks] 
