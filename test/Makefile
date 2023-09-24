SRC_PATH=../src

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(SRC_PATH)/ghost_sd.v
VERILOG_SOURCES += $(SRC_PATH)/clock_divider.v
VERILOG_SOURCES += $(SRC_PATH)/ram_4k_block.v
VERILOG_SOURCES += $(SRC_PATH)/sd/sd.v
VERILOG_SOURCES += $(SRC_PATH)/sd/sd_fsm.v
VERILOG_SOURCES += $(SRC_PATH)/sd/cmd_driver/cmd_driver.v
VERILOG_SOURCES += $(SRC_PATH)/sd/cmd_driver/crc7.v
VERILOG_SOURCES += $(SRC_PATH)/sd/d_driver/d_driver.v
VERILOG_SOURCES += $(SRC_PATH)/sd/d_driver/crc16.v

TOPLEVEL = ghost_sd

MODULE = ghost_sd_tb

include $(shell cocotb-config --makefiles)/Makefile.sim

all: 
	$(MAKE) -C sd all

# Open waveform
wave:
	gtkwave wave.vcd \
		--rcvar 'fontname_signals Monospace 20' \
        	--rcvar 'fontname_waves Monospace 20' \
        	--rcvar 'scale_to_time_dimension n'

cleanall:
	$(MAKE) clean
	rm -rf __pycache__ wave.vcd results.xml 
	$(MAKE) -C sd cleanall
