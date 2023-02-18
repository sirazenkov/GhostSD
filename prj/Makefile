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
	--pre-pack constraints.py 
timing:
	icetime -d lp1k -P cm36 work/ghost_sd.asc

bitstream:
	icepack work/ghost_sd.asc work/ghost_sd.bin

###### Use sudo ######
program:
	icesprog -g PA1 -w 0
	icesprog -g PB1 -w 0
	icesprog -c 3 work/ghost_sd.bin

reset:
	icesprog -g PA1 -w 1 
	icesprog -g PA1 -w 0 

start:
	icesprog -g PB1 -w 1 
	icesprog -g PB1 -w 0 

read_fail:
	icesprog -g PE2 -r
######################

clean:
	rm -rf work
