SRC_PATH=../../src/sd

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(SRC_PATH)/sd.v
VERILOG_SOURCES += $(SRC_PATH)/transceiver/transceiver.v
VERILOG_SOURCES += $(SRC_PATH)/transceiver/clock_divider.v
VERILOG_SOURCES += $(SRC_PATH)/transceiver/cmd_driver/cmd_driver.v
VERILOG_SOURCES += $(SRC_PATH)/transceiver/cmd_driver/crc7.v
VERILOG_SOURCES += $(SRC_PATH)/transceiver/d_driver/d_driver.v
VERILOG_SOURCES += $(SRC_PATH)/transceiver/d_driver/crc16.v

TOPLEVEL = sd

MODULE = sd_tb

include $(shell cocotb-config --makefiles)/Makefile.sim

all: 
	$(MAKE) -C transceiver/d_driver all
	$(MAKE) -C transceiver/cmd_driver all

# Open waveform
wave:
	gtkwave wave.vcd \
		--rcvar 'fontname_signals Monospace 20' \
        	--rcvar 'fontname_waves Monospace 20' \
        	--rcvar 'scale_to_time_dimension n'

cleanall:
	$(MAKE) clean
	rm -rf __pycache__ wave.vcd results.xml 
	$(MAKE) -C transceiver/cmd_driver clean
	$(MAKE) -C transceiver/d_driver cleanall
