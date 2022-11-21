//=======================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: Top module of GhostSD project
//=======================================================================

module ghost_sd
	(
	input iclk, // 36 MHz system clock
	input irst, // Reset button
	
	input istart, // Start button

	// SD lines
	inout iocmd_sd,		// CMD line
	inout [3:0] iodata_sd,	// D[3:0] line
	output oclk_sd,		// CLK line

	output status_led	// Blinking - running operation
				// OFF - failed
				// ON - success
	);

	localparam [255:0] key = 256'h34d20ac43f554f1d2fd101496787e3954e39d417e33528f13c005501aa1a9e47;
	localparam [63:0] IV = 64'hb97b7f467edaefd8;
	
	wire gost_done;
	wire [63:0] res_block;
	reg [63:0] block = IV;

	gost gost_inst
	(
	.irst(irst),
        .iclk(iclk),

        .istart(istart),
        .ienc_dec(1'b0), // 0 - encrypt, 1 - decrypt

        .ikey(key),
        .iblock(block),

        .oblock(res_block),
        .odone(gost_done)
	);

	ram_4k_block raw_block
	(
		.waddr(),
		.raddr(),
 		.din(),
 		.write_en(),
		.wclk(),
		rclk(iclk),
 		.dout()
	);

	ram_4k_block processed_block
	(
		.waddr(),
		.raddr(),
 		.din(),
 		.write_en(),
		.wclk(iclk),
		.rclk(),
 		.dout()
	);

	always @(posedge iclk)
	begin
		if(gost_done == 1'b1)
		begin
			block <= res_block;
		end
	end

	assign iodata_sd = block[63:60];

endmodule
