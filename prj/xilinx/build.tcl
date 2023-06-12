open_project ghost_sd.xpr

set_param general.maxThreads 32

synth_design -top ghost_sd
opt_design
place_design
phys_opt_design
route_design

write_bitstream -force ghost_sd.bit