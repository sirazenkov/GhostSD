open_hw_manager
connect_hw_server
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/003017AEE414A]
open_hw_target
set_property PROGRAM.FILE ./ghost_sd.runs/impl_1/ghost_sd.bit [lindex [get_hw_devices] 1]
program_hw_devices [lindex [get_hw_devices] 1]
close_hw_target
close_hw_manager
