## Clock signal 125 MHz
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports iclk]
create_clock -period 8.000 -name sys_clk_pin -waveform {0.000 4.000} -add [get_ports iclk]

##LEDs
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports osuccess]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports ofail]

##Buttons
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports istart]
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33} [get_ports irst]

##Pmod Header JA
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports {iodata_sd[2]}]
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports iocmd_sd]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {iodata_sd[0]}]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {iodata_sd[3]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports oclk_sd]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {iodata_sd[1]}]







