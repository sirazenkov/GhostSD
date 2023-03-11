SRC_PATH=../../../../src/sd/cmd_driver

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(SRC_PATH)/crc7.v

TOPLEVEL = crc7

MODULE = crc7_tb

include $(shell cocotb-config --makefiles)/Makefile.sim

# Open waveform
wave:
	gtkwave wave.vcd \
		--rcvar 'fontname_signals Monospace 20' \
        	--rcvar 'fontname_waves Monospace 20' \
        	--rcvar 'scale_to_time_dimension n'

cleanall:
	$(MAKE) clean
	rm -rf __pycache__ wave.vcd results.xml 
