SRC_PATH="../../../../../src/sd/transceiver/d_driver"

all:

# Design simulation
all:
	mkdir work
	iverilog -o work/crc16_tb crc16_tb.v $(SRC_PATH)/crc16.v 
	./work/crc16_tb

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
