SRC_PATH=../../../../src/sd/transceiver/d_driver

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(SRC_PATH)/d_driver.v
VERILOG_SOURCES += $(SRC_PATH)/crc16.v

TOPLEVEL = d_driver

MODULE = d_driver_tb

include $(shell cocotb-config --makefiles)/Makefile.sim

all: 
	$(MAKE) -C crc16 all

# Open waveform
wave:
	gtkwave wave.vcd \
		--rcvar 'fontname_signals Monospace 20' \
        	--rcvar 'fontname_waves Monospace 20' \
        	--rcvar 'scale_to_time_dimension n' \
		--script=add_waves.tcl

cleanall:
	$(MAKE) clean
	rm -rf __pycache__ wave.vcd results.xml 
	$(MAKE) -C crc16 clean
