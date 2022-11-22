all: synth placeNroute timing bitstream

synth: 
	mkdir work
	yosys synth.ys

placeNroute:
	nextpnr-ice40 \
	--lp1k --package cm36 \
        --json work/ghost_sd.json \
        --pcf ghost_sd.pcf \
        --asc work/ghost_sd.asc \
        --freq 36

timing:
	icetime -d lp1k work/ghost_sd.asc

bitstream:
	icepack work/ghost_sd.asc work/ghost_sd.bin

program:
	iceprog ghost_sd.bin

clean:
	rm -rf work
