SRC_PATH=../../../src/sd/cmd_driver

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(SRC_PATH)/cmd_driver.v
VERILOG_SOURCES += $(SRC_PATH)/crc7.v

TOPLEVEL = cmd_driver

MODULE = cmd_driver_tb

include $(shell cocotb-config --makefiles)/Makefile.sim

all: 
	$(MAKE) -C crc7 all

# Open waveform
wave:
	gtkwave wave.vcd \
		--rcvar 'fontname_signals Monospace 20' \
        	--rcvar 'fontname_waves Monospace 20' \
        	--rcvar 'scale_to_time_dimension n'

cleanall:
	$(MAKE) clean
	rm -rf __pycache__ wave.vcd results.xml 
	$(MAKE) -C crc7 cleanall
