//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.07 Education
//Created Time: 2023-04-28 09:52:41

create_clock -name iclk -period 37.037 -waveform {0 18.518} [get_ports {iclk}]

create_generated_clock -name otp_clk
                       -source [get_ports {iclk}]
                       -master_clock iclk
                       -multiply_by 50
                       -divide_by 9
                       [get_pins {clock_divider_inst/rPLL_inst_otp/rpll_inst/CLKOUT}]

create_generated_clock -name fast_clk
                       -source [get_ports {iclk}]
                       -master_clock iclk
                       -multiply_by 13
                       -divide_by 7
                       [get_pins {clock_divider_inst/rPLL_inst_sd/rpll_inst/CLKOUT}]
create_generated_clock -name sd_fast_clk
                       -source [get_pins {clock_divider_inst/rPLL_inst_sd/rpll_inst/CLKOUT}]
                       -master_clock fast_clk
                       -edges{1 2 3}
                       -add
                       [get_pins {clock_divider_inst/DCS_inst/dcs_inst/CLKOUT}]
create_generated_clock -name sd_fast_clk_out
                       -source [get_pins {clock_divider_inst/DCS_inst/dcs_inst/CLKOUT}]
                       -master_clock sd_fast_clk
                       -edges{1 2 3}
                       -add
                       [get_ports {oclk_sd}]

create_generated_clock -name slow_clk
                       -source [get_pins {clock_divider_inst/rPLL_inst_sd/rpll_inst/CLKOUT}]
                       -master_clock fast_clk
                       -multiply_by 1
                       -divide_by 126
                       [get_pins {clock_divider_inst/rPLL_inst_sd/rpll_inst/CLKOUTD}]
create_generated_clock -name sd_slow_clk
                       -source [get_pins {clock_divider_inst/rPLL_inst_sd/rpll_inst/CLKOUTD}]
                       -master_clock slow_clk
                       -edges{1 2 3}
                       -add
                       [get_pins {clock_divider_inst/DCS_inst/dcs_inst/CLKOUT}]
create_generated_clock -name sd_slow_clk_out
                       -source [get_pins {clock_divider_inst/DCS_inst/dcs_inst/CLKOUT}]
                       -master_clock sd_slow_clk
                       -edges{1 2 3}
                       -add
                       [get_ports {oclk_sd}]

set_clock_groups -asynchronous -group [get_clocks {otp_clk}] -group [get_clocks {sd_fast_clk}]
set_clock_groups -asynchronous -group [get_clocks {otp_clk}] -group [get_clocks {sd_slow_clk}]
set_clock_groups -exclusive -group [get_clocks {sd_slow_clk}] -group [get_clocks {sd_fast_clk}]
set_clock_groups -exclusive -group [get_clocks {sd_slow_clk}] -group [get_clocks {sd_fast_clk_out}]
set_clock_groups -exclusive -group [get_clocks {sd_fast_clk}] -group [get_clocks {sd_slow_clk_out}]

set_false_path -from [get_clocks {otp_clk}] -to [get_clocks {sd_fast_clk}]
set_false_path -from [get_clocks {otp_clk}] -to [get_clocks {sd_slow_clk}]
set_false_path -from [get_clocks {sd_fast_clk}] -to [get_clocks {otp_clk}]
set_false_path -from [get_clocks {sd_slow_clk}] -to [get_clocks {otp_clk}]

set_false_path -to [get_ports {ofail osuccess}]
set_false_path -from [get_ports {irst_n istart_n}]

set_false_path -from [get_regs {rst_s0}]
set_false_path -from [get_regs {start_s0}]

set_input_delay -clock [get_clocks {sd_fast_clk_out}]
                -min 2.5
                [get_ports {iocmd_sd, iodata_sd[*]}]
set_input_delay -clock [get_clocks {sd_fast_clk_out}]
                -max 14
                [get_ports {iocmd_sd, iodata_sd[*]}]
set_output_delay -clock [get_clocks {sd_fast_clk_out}]
                -min -2
                [get_ports {iocmd_sd, iodata_sd[*]}]
set_output_delay -clock [get_clocks {sd_fast_clk_out}]
                -max 6
                [get_ports {iocmd_sd, iodata_sd[*]}]

set_input_delay -clock [get_clocks {sd_slow_clk_out}]
                -min 0
                [get_ports {iocmd_sd, iodata_sd[*]}]
set_input_delay -clock [get_clocks {sd_slow_clk_out}]
                -max 50
                [get_ports {iocmd_sd, iodata_sd[*]}]
set_output_delay -clock [get_clocks {sd_slow_clk_out}]
                -min -5
                [get_ports {iocmd_sd, iodata_sd[*]}]
set_output_delay -clock [get_clocks {sd_slow_clk_out}]
                -max 5
                [get_ports {iocmd_sd, iodata_sd[*]}]
