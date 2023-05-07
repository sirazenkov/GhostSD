set_false_path -to [get_ports {ofail osuccess}]
set_false_path -from [get_ports {irst istart}]

set_false_path -from [get_cells rst_reg]
set_false_path -from [get_cells start_reg]

set_false_path -from [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/mmcm_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/mmcm_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/mmcm_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/mmcm_adv_inst/CLKOUT0]]

create_generated_clock -name sd_slow_clk -source [get_ports iclk] -divide_by 512 -add -master_clock sys_clk_pin [get_pins {clock_divider_inst/counter[8]_i_2__0/O}]
set_clock_groups -name slowNfast -logically_exclusive -group [get_clocks [list sd_slow_clk [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/mmcm_adv_inst/CLKOUT1]]]]

create_generated_clock -name sd_fast_clk_out -source [get_pins clock_divider_inst/clk_gen_inst/inst/mmcm_adv_inst/CLKOUT1] -multiply_by 1 -add -master_clock sd_fast_clk_clk_gen [get_ports oclk_sd]

set_input_delay -clock [get_clocks sd_fast_clk_out] -min 2.500 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]
set_input_delay -clock [get_clocks sd_fast_clk_out] -max 14.000 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]
set_output_delay -clock [get_clocks sd_fast_clk_out] -min -2.000 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]
set_output_delay -clock [get_clocks sd_fast_clk_out] -max 6.000 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]
