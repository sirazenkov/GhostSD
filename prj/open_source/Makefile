YOSYS =

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
	--opt-timing \
	--threads 4 \
	--tmg-ripup \
	--parallel-refine \
	--pre-pack constraints.py

timing:
	icetime -d lp1k -P cm36 -p ghost_sd.pcf work/ghost_sd.asc -c 36 -m -t

bitstream:
	icepack work/ghost_sd.asc work/ghost_sd.bin

###### Use sudo ######
program:
	icesprog work/ghost_sd.bin
	icesprog -c 3
	icesprog -g PA7 -m out
	icesprog -g PA5 -m out
	icesprog -g PA7 -w 1
	icesprog -g PA5 -w 1

reset:
	icesprog -g PA7 -w o
	sleep 1
	icesprog -g PA7 -w 1

start:
	icesprog -g PA5 -m out
	icesprog -g PA5 -w 0
	sleep 1
	icesprog -g PA5 -w 1

read_fail:
	icesprog -g PA6 -m in
	icesprog -g PA6 -r
######################

clean:
	rm -rf work
