//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.07 Education
//Created Time: 2023-04-28 09:52:41
create_clock -name iclk -period 37.037 -waveform {0 18.518} [get_ports {iclk}]
create_generated_clock -name otp_clk
                       -source [get_ports {iclk}]
                       -master_clock iclk
                       -multiply_by 11
                       -divide_by 3
                       [get_pins {clock_divider_inst/rPLL_inst/rpll_inst/CLKOUT}]
create_generated_clock -name clk_0p8M
                       -source [get_pins {clock_divider_inst/rPLL_inst/rpll_inst/CLKOUT}]
                       -master_clock otp_clk
                       -multiply_by 1
                       -divide_by 128
                       [get_pins {clock_divider_inst/rPLL_inst/rpll_inst/CLKOUTD}]
create_generated_clock -name slow_clk
                       -source [get_pins {clock_divider_inst/rPLL_inst/rpll_inst/CLKOUTD}]
                       -master_clock clk_0p8M
                       -multiply_by 1
                       -divide_by 2
                       [get_pins {clock_divider_inst/CLKDIV2_slow_inst/clkdiv_inst/CLKOUT}]
create_generated_clock -name sd_slow_clk
                       -source [get_pins {clock_divider_inst/CLKDIV2_slow_inst/clkdiv_inst/CLKOUT}]
                       -master_clock slow_clk
                       -edges{1 2 3}
                       [get_pins {clock_divider_inst/DCS_inst/dcs_inst/CLKOUT}]
create_generated_clock -name fast_clk
                       -source [get_pins {clock_divider_inst/rPLL_inst/rpll_inst/CLKOUT}]
                       -master_clock otp_clk
                       -multiply_by 1
                       -divide_by 2
                       [get_pins {clock_divider_inst/CLKDIV2_fast_inst/clkdiv_inst/CLKOUT}]
create_generated_clock -name sd_fast_clk
                       -source [get_pins {clock_divider_inst/CLKDIV2_fast_inst/clkdiv_inst/CLKOUT}]
                       -master_clock fast_clk
                       -edges{1 2 3}
                       -add
                       [get_pins {clock_divider_inst/DCS_inst/dcs_inst/CLKOUT}]
