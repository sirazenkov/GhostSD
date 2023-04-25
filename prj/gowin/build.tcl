add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/prj/gowin/ghost_sd/src/clock_divider_pll.v"
add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/prj/gowin/ghost_sd/src/gowin_dcs/gowin_dcs.v"
add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/prj/gowin/ghost_sd/src/gowin_rpll/gowin_rpll.v"
add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/src/ghost_sd.v"
add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/src/otp_gen/gost/gost.v"
add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/src/otp_gen/gost/round/round.v"
add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/src/otp_gen/gost/round/s_box.v"
add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/src/otp_gen/otp_gen.v"
add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/src/ram_4k_block.v"
add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/src/sd/cmd_driver/cmd_driver.v"
add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/src/sd/cmd_driver/crc7.v"
add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/src/sd/d_driver/crc16.v"
add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/src/sd/d_driver/d_driver.v"
add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/src/sd/sd.v"
add_file -type verilog "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/src/sd/sd_fsm.v"
add_file -type cst "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/prj/gowin/ghost_sd/src/physical.cst"
add_file -type sdc "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/prj/gowin/ghost_sd/src/timing.sdc"
add_file -type gao "C:/Users/semen/Documents/CS/MyProjects/GhostSD/GhostSD/prj/gowin/ghost_sd/src/ghost_sd.rao"
set_device GW2A-LV18PG256C8/I7 -name GW2A-18C
set_option -synthesis_tool gowinsynthesis
set_option -output_base_name ghost_sd
set_option -verilog_std v2001
set_option -vhdl_std vhd1993
set_option -dsp_balance 0
set_option -print_all_synthesis_warning 0
set_option -allow_duplicate_modules 0
set_option -multi_file_compilation_unit 1
set_option -auto_constraint_io 0
set_option -default_enum_encoding default
set_option -compiler_compatible 1
set_option -disable_io_insertion 0
set_option -fix_gated_and_generated_clocks 1
set_option -frequency Auto
set_option -looplimit 2000
set_option -maxfan 10000
set_option -pipe 1
set_option -resolve_multiple_driver 0
set_option -resource_sharing 1
set_option -retiming 0
set_option -run_prop_extract 1
set_option -rw_check_on_ram 1
set_option -supporttypedflt 0
set_option -symbolic_fsm_compiler 1
set_option -synthesis_onoff_pragma 0
set_option -update_models_cp 0
set_option -write_apr_constraint 1
set_option -gen_sdf 0
set_option -gen_io_cst 0
set_option -gen_ibis 0
set_option -gen_posp 0
set_option -gen_text_timing_rpt 0
set_option -gen_sim_netlist 0
set_option -show_init_in_vo 0
set_option -show_all_warn 0
set_option -timing_driven 1
set_option -use_scf 0
set_option -ireg_in_iob 1
set_option -oreg_in_iob 1
set_option -ioreg_in_iob 1
set_option -cst_warn_to_error 1
set_option -rpt_auto_place_io_info 0
set_option -place_option 0
set_option -route_option 0
set_option -inc 
set_option -route_maxfan 23
set_option -use_jtag_as_gpio 0
set_option -use_sspi_as_gpio 1
set_option -use_mspi_as_gpio 0
set_option -use_ready_as_gpio 0
set_option -use_done_as_gpio 0
set_option -use_reconfign_as_gpio 0
set_option -use_mode_as_gpio 0
set_option -use_i2c_as_gpio 0
set_option -power_on_reset 0
set_option -bit_format bin
set_option -bit_crc_check 1
set_option -bit_compress 0
set_option -bit_encrypt 0
set_option -bit_encrypt_key 00000000000000000000000000000000
set_option -bit_security 1
set_option -bit_incl_bsram_init 1
set_option -bg_programming off
set_option -hotboot 0
set_option -i2c_slave_addr 00
set_option -secure_mode 0
set_option -loading_rate default
set_option -spi_flash_addr 00000000
set_option -program_done_bypass 0
set_option -wakeup_mode 0
set_option -user_code default
set_option -unused_pin default
run all