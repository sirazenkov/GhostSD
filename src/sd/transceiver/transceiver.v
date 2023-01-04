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

	input istart, // Start Command-Response[-Data] transaction
	
	input isel_clk, // Select CLK frequency: '1' - 18 MHz, '0'- 281.25 kHz

	// Command & Response
	input [5:0] icmd_index,	// Command index
	input [31:0] icmd_arg,	// Command argument 
	input ilong_resp,	// R2 response
	output [31:0] oresp,	// Received response
	output ovalid,		// Valid response

	output [9:0] oaddr, // Data address in RAM

        // RAM for received data
        output [3:0] owdata,
        output owrite_en,

        // RAM with processed data (for sending)
        input [3:0] irdata,

	input idata_start,
        output odata_crc_fail,
	output odata_done,
		
	input icmd_start,
	output ocmd_crc_fail,	// At least one CRC check failed
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

		.istart(icmd_start),

		.icmd_index(icmd_index),
		.icmd_arg(icmd_arg),
		.ilong_resp(ilong_resp),
		
		.oresp(oresp),

		.odone(ocmd_done)	
	);

	wire start_d;

	// D lines driver
	d_driver d_driver_inst
	(
		.irst(irst),
		.iclk(clk_sd),
		
		.idata_sd(idata_sd),
		.odata_sd(odata_sd),

		.istart(idata_start),
		
		.oaddr(oaddr),
		.owdata(owdata),
		.owrite_en(owrite_en),
		.irdata(irdata),

		.ocrc_fail(orc_fail),
		.odone(odata_done)
	);

endmodule

