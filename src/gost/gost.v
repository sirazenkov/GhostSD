//=============================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: GOST (Magma) block cipher module
//=============================================

module gost
	(
	input irst,
	input iclk,
	
	input istart,
	input ienc_dec, // 0 - encrypt, 1 - decrypt

	input [255:0] ikey,
	input [63:0] iblock,
	
	output [63:0] oblock
	);

	reg start_sh = 1'b0;
	wire start;
	always @(posedge iclk)
		start_sh <= start;
	assign start = (istart == 1'b1) && (start_sh == 1'b0);

	round round_inst
	(
		.irst(irst),
		.iclk(iclk),
		
		.istart(),

		.iblock(),
		.iround_key(),

		.oblock(),
		.odone()
	);

endmodule
