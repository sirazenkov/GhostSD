add_file -type verilog "./src/define.vh"
add_file -type verilog "./src/clock_divider.v"
add_file -type verilog "./src/gowin_dcs/gowin_dcs.v"
add_file -type verilog "./src/gowin_rpll/gowin_rpll_otp.v"
add_file -type verilog "./src/gowin_rpll/gowin_rpll_sd.v"
add_file -type verilog "../../src/ghost_sd.v"
add_file -type verilog "../../src/otp_gen/gost/gost.v"
add_file -type verilog "../../src/otp_gen/gost/round/round.v"
add_file -type verilog "../../src/otp_gen/gost/round/s_box.v"
add_file -type verilog "../../src/otp_gen/otp_gen.v"
add_file -type verilog "../../src/ram_4k_block.v"
add_file -type verilog "../../src/sd/cmd_driver/cmd_driver.v"
add_file -type verilog "../../src/sd/cmd_driver/crc7.v"
add_file -type verilog "../../src/sd/d_driver/crc16.v"
add_file -type verilog "../../src/sd/d_driver/d_driver.v"
add_file -type verilog "../../src/sd/sd.v"
add_file -type verilog "../../src/sd/sd_fsm.v"
add_file -type cst "./src/physical.cst"
add_file -type sdc "./src/timing.sdc"

set_device GW2A-LV18PG256C8/I7 -name GW2A-18C

set_option -output_base_name ghost_sd

set_option -verilog_std v2001

set_option -place_option 1
set_option -route_option 1

set_option -use_sspi_as_gpio 1

run all
