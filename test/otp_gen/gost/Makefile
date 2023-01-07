SRC_PATH=../../../src/otp_gen/gost

all: synth sim

# Design and testbench synthesis
synth:
	mkdir work
	iverilog -o work/gost_tb gost_tb.v \
		$(SRC_PATH)/gost.v \
		$(SRC_PATH)/round/round.v \
		$(SRC_PATH)/round/s_box.v

# Launch simulation
sim:
	./work/gost_tb

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
