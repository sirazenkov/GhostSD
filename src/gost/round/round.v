//=============================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: GOST (Magma) block cipher round
//=============================================

module round
        (
	input irst,
	input iclk,

	input istart,

	input [63:0] iblock,
	input [31:0] iround_key,

	output oblock,
	output odone
        );

	reg start_sh = 1'b0;
        wire start;
        always @(posedge iclk)
                start_sh <= start;
        assign start = (istart == 1'b1) && (start_sh == 1'b0);	

	localparam [1:0]
		IDLE = 2'b00,
		ADD = 2'b01,
		SBOX = 2'b11;
	reg state = IDLE;

	reg [31:0] half_block = {32{1'b0}};
	wire [31:0] s_box_output;
	s_box s_box_inst
	(
		.iword(half_block),
		.oword(s_box_output)
	);

	always @(posedge iclk)
	begin
		if(irst == 1'b1)
		begin
			state = IDLE;
			half_block = {32{1'b0}};
		end
		else
		begin
			case(state)
				IDLE:
				begin
					if(start == 1'b1)
					begin
						half_block <= iblock[31:0] + iround_key;
						state <= ADD;
					end
				end
				ADD:
				begin
					half_block <= s_box_output;
					state <= SBOX;
				end
				SBOX:
				begin
					half_block <= ((half_block << 11) | (half_block >> (32-11))) ^
							iblock[63:32];
					state <= IDLE;
				end
			endcase
		end
	end

	assign odone = state == IDLE;

endmodule
