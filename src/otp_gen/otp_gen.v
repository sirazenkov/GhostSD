//==================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: OTP generator (based on GOST "Magma")
//==================================================

module otp_gen
	(
	input iclk, // System clock
	input irst, // Global reset

	input istart,

	input [255:0] ikey,
	input [63:0] iIV,

	// RAM for OTP
	output [9:0] oaddr,
	output [3:0] owdata,
	output owrite_en,

	output odone
	);

	localparam [1:0]
		IDLE = 2'b00,
		GEN_BLOCK = 2'b01,
		WRITE_BLOCK = 2'b11;
	reg [1:0] state = IDLE;
	wire [1:0] next_state;

	reg []

	always @(*) begin
		case(state)
			IDLE:
			GEN_BLOCK:
			WRITE_BLOCK:
		endcase
	end

	always_ff @(posedge iclk) begin
		if(irst)
			state <= IDLE;
		else
			state <= next_state;
	end

	reg start_gost;
	reg [63:0] block;
	wire done_gost;

	gost gost_inst (
		.irst(irst),
		.iclk(iclk),

		.istart(start_gost),

        	.ikey(ikey),
        	.iblock(block),

        	.oblock(owdata),
        	.done(done_gost)
	);

endmodule
