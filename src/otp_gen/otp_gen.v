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

	input istart, // Generate new block of the pad

	input inew_otp, // Start new OTP from IV

	input [255:0] ikey,
	input [31:0] iIV, // Initialization vector

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

	reg [9:0] counter;

	always @(*) begin
		next_state = state;
		case(state)
			IDLE:
				if(istart)
					next_state = GEN_BLOCK;
			GEN_BLOCK:
				if(done_gost)
					next_state = WRITE_BLOCK;
			WRITE_BLOCK:
				if(&counter[3:0]) begin
					if(&counter[9:4])
						next_state = IDLE;
					next_state = GEN_BLOCK;
				end
		endcase
	end

	always @(posedge iclk) begin
		if(irst)
			state <= IDLE;
		else
			state <= next_state;
	end

	reg start_gost;
	reg [63:0] plain_block;
	wire [63:0] enc_block;
	wire done_gost;

	always @(posedge iclk) begin
		if(istart && next_state == GEN_BLOCK)
			start_gost <= 1'b1;
		else
			start_gost <= 1'b0;

		case(state)
			IDLE:
				if(inew_otp)
					plain_block <= {iIV, {32{1'b0}}};
			GEN_BLOCK:
				if(done_gost)
					plain_block <= plain_block + 1'b1;
			WRITE_BLOCK:
				counter <= counter + 1;
		endcase
	end

	gost gost_inst (
		.irst(irst),
		.iclk(iclk),

		.istart(start_gost),

        	.ikey(ikey),
        	.iblock(plain_block),

        	.oblock(enc_block),
        	.done(done_gost)
	);

	assign oaddr = counter;
	assign owdata = enc_block[4*(16-counter)-1:4*(16-counter-1)];
	assign owrite_en = state == WRITE_BLOCK;
	assign odone = state == IDLE;

endmodule
