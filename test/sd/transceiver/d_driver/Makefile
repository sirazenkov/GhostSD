SRC_PATH=../../../../src/sd/transceiver/d_driver

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(SRC_PATH)/d_driver.v
VERILOG_SOURCES += $(SRC_PATH)/crc16.v

TOPLEVEL = d_driver

MODULE = d_driver_tb

all: 
	include $(shell cocotb-config --makefiles)/Makefile.sim
	$(MAKE) -C crc16 all

# Open waveform
wave:
	gtkwave work/wave.vcd \
		--rcvar 'fontname_signals Monospace 20' \
        	--rcvar 'fontname_waves Monospace 20' \
        	--rcvar 'scale_to_time_dimension n' \
		--script=add_waves.tcl

# Delete all artifacts
clean:
	rm -r work
	$(MAKE) -C crc16 clean
