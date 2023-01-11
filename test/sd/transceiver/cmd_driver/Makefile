SRC_PATH=../../../../src/sd/transceiver/cmd_driver

all: synth sim
	$(MAKE) -C crc7 all

# Design and testbench synthesis
synth:
	mkdir work
	iverilog -o work/cmd_driver_tb \
	cmd_driver_tb.v \
	$(SRC_PATH)/cmd_driver.v \
	$(SRC_PATH)/crc7.v

# Launch simulation
sim:
	./work/cmd_driver_tb

# Open waveform
wave:
	gtkwave work/wave.ocd \
		--rcvar 'fontname_signals Monospace 20' \
        	--rcvar 'fontname_waves Monospace 20' \
        	--rcvar 'scale_to_time_dimension n' \
		--script=add_waves.tcl

# Delete all artifacts
clean:
	rm -r work
	$(MAKE) -C crc7 clean
