create_clock -period 8.000 -name sys_clk_pin -waveform {0.000 4.000} -add [get_ports iclk]

create_generated_clock -name slow_clk \
                       -source [get_pins clock_divider_inst/clk_gen_inst/inst/plle2_adv_inst/CLKOUT2] \
                       -divide_by 32 \
                       [get_pins clock_divider_inst/counter_reg[4]/Q]

create_generated_clock -name sd_fast_clk \
                       -source [get_pins clock_divider_inst/clk_gen_inst/inst/plle2_adv_inst/CLKOUT1] \
                       -master_clock [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/plle2_adv_inst/CLKOUT1]] \
                       -divide_by 1 \
                       [get_pins clock_divider_inst/BUFGMUX_CTRL_inst/O] \
                       -add
create_generated_clock -name sd_slow_clk \
                       -source [get_pins clock_divider_inst/counter_reg[4]/Q] \
                       -master_clock [get_clocks {slow_clk}] \
                       -divide_by 1 \
                       [get_pins clock_divider_inst/BUFGMUX_CTRL_inst/O] \
                       -add
                       
create_generated_clock -name sd_fast_clk_out \
                       -source [get_pins clock_divider_inst/BUFGMUX_CTRL_inst/O] \
                       -master_clock [get_clocks {sd_fast_clk}] \
                       -divide_by 1 \
                       [get_ports oclk_sd] \
                       -add
create_generated_clock -name sd_slow_clk_out \
                       -source [get_pins clock_divider_inst/BUFGMUX_CTRL_inst/O] \
                       -master_clock [get_clocks {sd_slow_clk}] \
                       -divide_by 1 \
                       [get_ports oclk_sd] \
                       -add                   

set_false_path -to [get_ports {ofail osuccess}]
set_false_path -from [get_ports {irst istart}]

set_false_path -from [get_cells rst_reg]
set_false_path -from [get_cells start_reg]

set_clock_groups -group [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/plle2_adv_inst/CLKOUT0]] -group [get_clocks {sd_fast_clk}] -asynchronous
set_clock_groups -group [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/plle2_adv_inst/CLKOUT0]] -group [get_clocks {sd_slow_clk}] -asynchronous

set_false_path -from [get_clocks {sd_fast_clk}] -to [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/plle2_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/plle2_adv_inst/CLKOUT0]] -to [get_clocks {sd_fast_clk}]

set_false_path -from [get_clocks {sd_slow_clk}] -to [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/plle2_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/plle2_adv_inst/CLKOUT0]] -to [get_clocks {sd_slow_clk}]

set_clock_groups -group [get_clocks -include_generated_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/plle2_adv_inst/CLKOUT1]] \
                 -group [get_clocks -include_generated_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/plle2_adv_inst/CLKOUT2]] \
                 -logically_exclusive

set_input_delay -clock [get_clocks sd_fast_clk_out] -min 2.500 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]
set_input_delay -clock [get_clocks sd_fast_clk_out] -max 14.000 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]
set_output_delay -clock [get_clocks sd_fast_clk_out] -min -2.000 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]
set_output_delay -clock [get_clocks sd_fast_clk_out] -max 6.000 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]

set_input_delay -clock [get_clocks sd_slow_clk_out] -min 0.000 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]
set_input_delay -clock [get_clocks sd_slow_clk_out] -max 50.000 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]
set_output_delay -clock [get_clocks sd_slow_clk_out] -min -5.000 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]
set_output_delay -clock [get_clocks sd_slow_clk_out] -max 5.000 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]
