create_clock -period 20.000 -name VIRTUAL_sd_fast_clk_clk_gen -waveform {0.000 10.000}
set_input_delay -clock [get_clocks VIRTUAL_sd_fast_clk_clk_gen] -min -add_delay 2.500 [get_ports {iodata_sd[*]}]
set_input_delay -clock [get_clocks VIRTUAL_sd_fast_clk_clk_gen] -max -add_delay 14.000 [get_ports {iodata_sd[*]}]
set_input_delay -clock [get_clocks VIRTUAL_sd_fast_clk_clk_gen] -min -add_delay 2.500 [get_ports iocmd_sd]
set_input_delay -clock [get_clocks VIRTUAL_sd_fast_clk_clk_gen] -max -add_delay 14.000 [get_ports iocmd_sd]
set_output_delay -clock [get_clocks VIRTUAL_sd_fast_clk_clk_gen] -min -add_delay -2.000 [get_ports {iodata_sd[*]}]
set_output_delay -clock [get_clocks VIRTUAL_sd_fast_clk_clk_gen] -max -add_delay 6.000 [get_ports {iodata_sd[*]}]
set_output_delay -clock [get_clocks VIRTUAL_sd_fast_clk_clk_gen] -min -add_delay -2.000 [get_ports iocmd_sd]
set_output_delay -clock [get_clocks VIRTUAL_sd_fast_clk_clk_gen] -max -add_delay 6.000 [get_ports iocmd_sd]
set_false_path -to [get_ports {ofail osuccess}]
set_false_path -from [get_ports {irst istart}]

set_false_path -from [get_cells rst_reg]
set_false_path -from [get_cells start_reg]

set_false_path -from [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/mmcm_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/mmcm_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/mmcm_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins clock_divider_inst/clk_gen_inst/inst/mmcm_adv_inst/CLKOUT0]]
