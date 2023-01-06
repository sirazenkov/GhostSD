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

	input [255:0] ikey,
	input [63:0] iblock,
	
	output [63:0] oblock,
	output odone
	);

	localparam
		IDLE = 1'b0,
		ENC = 1'b1;
	reg state = IDLE;
	wire start_round, round_done;
	assign start_round = state == ENC; 

	reg [4:0] counter = 5'd0;

	reg [63:0] block = {64{1'b0}};
	wire [63:0] round_oblock;
	reg [31:0] round_key = {32{1'b0}};

	always @(posedge iclk)
	begin
		if(irst == 1'b1)
		begin
			state = IDLE;
			counter = 5'b00000;
		end
		else
		begin
			case(state)
				IDLE:
				begin
					if(istart == 1'b1)
					begin
						state <= ENC;
						counter <= 5'b00000;	
						block <= iblock;
					end
				end
				ENC:
				begin
					if(round_done == 1'b1)
					begin
						counter <= counter + 1'b1;
						if(counter == 5'b11111) begin
							block <= (round_oblock[31:0] << 32) |
								round_oblock[63:32];
							state <= IDLE;
						end
						else
						begin
							block <= round_oblock;
						end
					end
				end
			endcase
		end
	end

	always @(*)
	begin
		case(counter)
			5'd0, 5'd8, 5'd16, 5'd31 : round_key <= ikey[255:224];
			5'd1, 5'd9, 5'd17, 5'd30 : round_key <= ikey[223:192];
			5'd2, 5'd10, 5'd18, 5'd29 : round_key <= ikey[191:160];
			5'd3, 5'd11, 5'd19, 5'd28 : round_key <= ikey[159:128];
			5'd4, 5'd12, 5'd20, 5'd27 : round_key <= ikey[127:96];
			5'd5, 5'd13, 5'd21, 5'd26 : round_key <= ikey[95:64];
			5'd6, 5'd14, 5'd22, 5'd25 : round_key <= ikey[63:32];
			5'd7, 5'd15, 5'd23, 5'd24 : round_key <= ikey[31:0];
		endcase
	end

	round round_inst
	(
		.irst(irst),
		.iclk(iclk),
		
		.istart(start_round),

		.iblock(block),
		.ikey(round_key),

		.oblock(round_oblock),
		.odone(round_done)
	);

	assign oblock = block;
	assign odone = state == IDLE;

endmodule
