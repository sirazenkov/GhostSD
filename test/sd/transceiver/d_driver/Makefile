SRC_PATH=../../../../src/sd/transceiver/d_driver

all: synth sim

# Design and testbench synthesis
synth:
	mkdir work
	iverilog -o work/d_driver_tb \
	d_driver_tb.v \
	$(SRC_PATH)/d_driver.v \
	$(SRC_PATH)/crc16.v

# Launch simulation
sim:
	./work/d_driver_tb

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
