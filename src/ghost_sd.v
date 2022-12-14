//==========================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: Top module of GhostSD project
//==========================================

module ghost_sd
	(
	input iclk, // 36 MHz system clock
	input irst,
	
	input istart,

	// SD lines
	inout iocmd_sd,		// CMD line
	inout [3:0] iodata_sd,	// D[3:0] line
	output oclk_sd,		// CLK line

	output osuccess,
	output ofail
	);
	
	`include "crypto.vh"
	
	wire icmd_sd, ocmd_sd, clk_sd;
	wire [3:0] idata_sd, odata_sd;

	wire gen_otp, otp_ready, new_otp;

	wire write_en_raw, write_en_otp;
	wire [3:0] wdata_raw, wdata_otp;
	wire [9:0] addr, addr_otp;
	wire [3:0] res_block;
	wire [3:0] block_otp, block_raw;

	wire success, fail;

	sd sd_inst (
        	.irst(irst),
		.iclk(iclk),

        	.icmd_sd(icmd_sd),
        	.ocmd_sd(ocmd_sd),
        	.idata_sd(idata_sd),
        	.odata_sd(odata_sd),
        	.oclk_sd(clk_sd),

        	.istart(istart),

        	.ogen_otp(gen_otp),
		.onew_otp(new_otp),

        	.iotp_ready(otp_ready),

        	.oaddr(addr),

        	.owdata(wdata_raw),
        	.owrite_en(write_en_raw),

        	.irdata(res_block),

        	.osuccess(success),
       		.ofail(fail)
        );

	otp_gen otp_gen_inst
	(
	.irst(irst),
        .iclk(iclk),

        .istart(gen_otp),
	
	.inew_otp(new_otp),

        .ikey(KEY),
	.iIV(IV),

        .oaddr(addr_otp),
        .owdata(wdata_otp),
	.owrite_en(write_en_otp),

	.odone(otp_ready)
	);

	ram_4k_block otp_block
	(
		.waddr(addr_otp),
		.raddr(addr),
 		.din(wdata_otp),
 		.write_en(write_en_otp),
		.wclk(iclk),
		.rclk(clk_sd),
 		.dout(block_otp)
	);

	ram_4k_block raw_block
	(
		.waddr(addr),
		.raddr(addr),
 		.din(wdata_raw),
 		.write_en(write_en_raw),
		.wclk(clk_sd),
		.rclk(clk_sd),
 		.dout(block_raw)
	);

	assign res_block = block_raw ^ block_otp;

	assign oclk_sd = clk_sd;
	assign iocmd_sd = ocmd_sd == 1'b0 ? 1'b0 : 1'bz;
	genvar i;
	generate
		for(i = 0; i < 4; i = i + 1) begin
			assign iodata_sd[i] = odata_sd[i] == 1'b0 ? 1'b0 : 1'bz;
		end
	endgenerate
	assign icmd_sd = iocmd_sd;
	assign idata_sd = iodata_sd;

	assign osuccess = success;
	assign ofail = fail;

endmodule
