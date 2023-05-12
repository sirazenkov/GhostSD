create_clock -period 8.000 -name sys_clk_pin -waveform {0.000 4.000} -add [get_ports iclk]

set_false_path -to [get_ports {ofail osuccess}]
set_false_path -from [get_ports {irst istart}]

set_false_path -from [get_cells clock_divider_inst/counter_reg*]
set_false_path -from [get_cells rst_reg]
set_false_path -from [get_cells start_reg]

set_false_path -from [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/mmcm_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/mmcm_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/mmcm_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/mmcm_adv_inst/CLKOUT0]]

set_input_delay -clock [get_clocks sd_fast_clk_clk_gen] -min 2.500 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]
set_input_delay -clock [get_clocks sd_fast_clk_clk_gen] -max 14.000 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]
set_output_delay -clock [get_clocks sd_fast_clk_clk_gen] -min -2.000 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]
set_output_delay -clock [get_clocks sd_fast_clk_clk_gen] -max 6.000 [get_ports -filter { NAME =~  "*io*" && DIRECTION == "INOUT" }]