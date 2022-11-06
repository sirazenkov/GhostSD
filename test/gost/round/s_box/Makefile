SRC_PATH=../../../../src/gost/round

all: synth sim

# Design and testbench synthesis
synth:
	mkdir work
	iverilog -o work/s_box_tb $(SRC_PATH)/s_box.v s_box_tb.v

# Launch simulation
sim:
	./work/s_box_tb

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
