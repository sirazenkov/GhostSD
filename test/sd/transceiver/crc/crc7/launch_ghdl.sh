mkdir work

ghdl -a --workdir=work \
	crc7_tb.vhd \
	../../../../../src/sd/transceiver/crc/crc7.vhd

ghdl -r --workdir=work crc7_tb --wave=./work/wave.ghw
