//================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: SD interface transceiver top module
//================================================

module transceiver
	(
	input irst, // Global reset
	input iclk, // System clock (36 MHz)

	// SD Bus
	input icmd_sd,		// CMD line
	output ocmd_sd,	
	input [3:0] idata_sd,	// D[3:0] line
	output [3:0] odata_sd,
	output oclk_sd,		// CLK line
	
	input isel_clk, // Select CLK frequency: '1' - 18 MHz, '0'- 281.25 kHz

	// Command & Response
	input [5:0] icmd_index,	// Command index
	input [31:0] icmd_arg,	// Command argument 
	output [31:0] oresp,	// Received response

	output [9:0] oaddr, 	// Data address in RAM

        // RAM for received data
        output [3:0] owdata,
        output owrite_en,

        // RAM with processed data (for sending)
        input [3:0] irdata,

	input istart_d_read, 	// Start reading data from SD
	input istart_d_write, 	// Start writing data to SD
        output odata_crc_fail,
	output odata_done,

	input istart_cmd,	// Start Command-Response transaction
	output ocmd_done
    	);

	wire clk_18MHz, clk_281kHz, clk_sd;

	// Get 18 Mhz and 281.25 kHz clocks from 36 MHz system clock
	clock_divider clock_divider_inst
	(
		.irst(irst),
		.iclk(iclk),
		.ofastclk(clk_18MHz),
		.oslowclk(clk_281kHz)
	);

	assign clk_sd = isel_clk == 1'b1 ? clk_18MHz : clk_281kHz;
	assign oclk_sd = clk_sd;

	// CMD line driver
	cmd_driver cmd_driver_inst
	(
		.irst(irst),
		.iclk(clk_sd),

		.icmd_sd(icmd_sd),
		.ocmd_sd(ocmd_sd),

		.istart(istart_cmd),

		.icmd_index(icmd_index),
		.icmd_arg(icmd_arg),
		
		.oresp(oresp),

		.odone(ocmd_done)	
	);

	// D lines driver
	d_driver d_driver_inst
	(
		.irst(irst),
		.iclk(clk_sd),
		
		.idata_sd(idata_sd),
		.odata_sd(odata_sd),

		.istart_read(istart_d_read),
		.istart_write(istart_d_write),

		.oaddr(oaddr),
		.owdata(owdata),
		.owrite_en(owrite_en),
		.irdata(irdata),

		.ocrc_fail(odata_crc_fail),
		.odone(odata_done)
	);

endmodule

