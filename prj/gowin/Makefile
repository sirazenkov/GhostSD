GOWIN = 

all:
	gw_sh build.tcl

program:
	programmer_cli --device GW2A-18C \
		       --run 2 \
		       --fsFile "$(shell pwd)/impl/pnr/ghost_sd.fs"

clean:
	rm -rf impl ghost_sd.gprj.user