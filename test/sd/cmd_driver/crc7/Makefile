SRC_PATH="../../../../src/sd/cmd_driver"

all: synth sim

# Design and testbench synthesis
synth:
	mkdir work
	iverilog -o work/crc7_tb crc7_tb.v $(SRC_PATH)/crc7.v 

# Launch simulation
sim:
	./work/crc7_tb

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
