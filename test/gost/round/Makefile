SRC_PATH=../../../src/gost/round

all: synth sim

# Design and testbench synthesis
synth:
	mkdir work
	iverilog -o work/round_tb round_tb.v \
		$(SRC_PATH)/round.v \
		$(SRC_PATH)/prefix_adder/prefix_adder.v \
		$(SRC_PATH)/prefix_adder/gen_prop_cell.v \
		$(SRC_PATH)/s_box.v

# Launch simulation
sim:
	./work/round_tb

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
