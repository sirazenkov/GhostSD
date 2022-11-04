//================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: SD interface transceiver top module
//================================================

module transceiver

	(
	input irst, // Global reset
	input iclk, // System clock (72 MHz)

	// SD Bus
	inout iocmd_sd,		// CMD line
	inout [3:0] iodata_sd,	// D[3:0] line
	output oclk_sd,		// CLK line

	input istart, // Start Command-Response[-Data] transaction
	
	input isel_clk, // Select CLK frequency: '1' - 18 MHz, '0'- 281.25 kHz

	// Sent Data
	input [5:0] icmd_index,	// Command index
	input [31:0] icmd_arg,	// Command argument 

	// Received Data
	inout [63:0] ioblock,	// GOST cipher block (64 bits)
	output [31:0] oresp,	// Received response
	output crc_fail,	// At least one CRC check failed
	output ovalid		// Block or response valid
    	);


	wire clk_18MHz, clk_281kHz, clk_sd;

	// Get 18 Mhz and 281.25 kHz clocks from 72 MHz system clock
	clock_divider clock_divider_inst
	(
		.irst(irst),
		.iclk(iclk),
		.ofastclk(clk_18MHz),
		.oslowclk(clk_281kHz)
	);

	assign clk_sd = (isel_clk == 1'b1) clk_18MHz ? clk_281kHz;
	assign oclk_sd = clk_sd;


	wire start_cmd, cmd_done;

	// CMD line driver
	cmd_driver cmd_driver_inst
	(
		.irst(irst),
		.iclk(clk_sd),

		.iocmd_sd(iocmd_sd),

		.istart(start_cmd),

		.icmd_index(icmd_index),
		.icmd_arg(icmd_arg),
		
		.oresp(oresp),

		.odone(cmd_done)	
	);

	wire start_d, send_rcv_data, d_done;

	// D lines driver
	d_driver d_driver_inst
	(
		.irst(irst),
		.iclk(clk_sd),
		
		.iodata_sd(iodata_sd),

		.istart(start_d),
		.isend_rcv(),

		.ioblock(ioblock),
		.ocrc_fail(),
		.odone(d_done)
	);

	assign ovalid = ;
endmodule
