SRC_PATH=../../src/otp_gen

all: synth sim
	$(MAKE) -C gost all

# Design and testbench synthesis
synth:
	mkdir work
	iverilog -o work/otp_gen_tb otp_gen_tb.v \
		$(SRC_PATH)/otp_gen.v \
		$(SRC_PATH)/gost/gost.v \
		$(SRC_PATH)/gost/round/round.v \
		$(SRC_PATH)/gost/round/s_box.v

# Launch simulation
sim:
	./work/otp_gen_tb

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
	$(MAKE) -C round clean
