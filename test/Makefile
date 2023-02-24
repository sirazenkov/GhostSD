SRC_PATH=../src

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(SRC_PATH)/sd/sd.v
VERILOG_SOURCES += $(SRC_PATH)/sd/transceiver/transceiver.v
VERILOG_SOURCES += $(SRC_PATH)/sd/transceiver/clock_divider.v
VERILOG_SOURCES += $(SRC_PATH)/sd/transceiver/cmd_driver/cmd_driver.v
VERILOG_SOURCES += $(SRC_PATH)/sd/transceiver/cmd_driver/crc7.v
VERILOG_SOURCES += $(SRC_PATH)/sd/transceiver/d_driver/d_driver.v
VERILOG_SOURCES += $(SRC_PATH)/sd/transceiver/d_driver/crc16.v
VERILOG_SOURCES += $(SRC_PATH)/otp_gen/otp_gen.v
VERILOG_SOURCES += $(SRC_PATH)/otp_gen/gost/gost.v
VERILOG_SOURCES += $(SRC_PATH)/otp_gen/gost/round/round.v
VERILOG_SOURCES += $(SRC_PATH)/otp_gen/gost/round/s_box.v

TOPLEVEL = ghost_sd

MODULE = ghost_sd_tb

include $(shell cocotb-config --makefiles)/Makefile.sim

all: 
	$(MAKE) -C otp_gen all
	$(MAKE) -C sd/transceiver/d_driver all
	$(MAKE) -C sd/transceiver/cmd_driver all

# Open waveform
wave:
	gtkwave wave.vcd \
		--rcvar 'fontname_signals Monospace 20' \
        	--rcvar 'fontname_waves Monospace 20' \
        	--rcvar 'scale_to_time_dimension n'

cleanall:
	$(MAKE) clean
	rm -rf __pycache__ wave.vcd results.xml 
	$(MAKE) -C otp_gen clean
	$(MAKE) -C sd/transceiver/cmd_driver clean
	$(MAKE) -C sd/transceiver/d_driver cleanall
