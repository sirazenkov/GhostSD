SRC_PATH=../../src/sd

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(SRC_PATH)/sd_fsm.v

TOPLEVEL = sd_fsm

MODULE = sd_fsm_tb

include $(shell cocotb-config --makefiles)/Makefile.sim

all:
	$(MAKE) -C cmd_driver all
	$(MAKE) -C d_driver all

# Open waveform
wave:
	gtkwave wave.vcd \
		--rcvar 'fontname_signals Monospace 20' \
        	--rcvar 'fontname_waves Monospace 20' \
        	--rcvar 'scale_to_time_dimension n'

cleanall:
	$(MAKE) clean
	rm -rf __pycache__ wave.vcd results.xml 
	$(MAKE) -C cmd_driver cleanall
	$(MAKE) -C d_driver cleanall
