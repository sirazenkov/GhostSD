//===============================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: D lines driver
//===============================

module d_driver
	(
	input irst,
	input iclk,

	inout [4:0] iodata_sd,

	input istart
	input isend_rcv, // 0 - send, 1 - receive block of data

	inout [15:0] ioblock,
	output ocrc_fail,
	output odone
	);

	reg start_sh = 1'b0;
	wire start;
	always @(posedge iclk)
		start_sh <= start;
	assign start = (istart == 1'b1) && (start_sh == 1'b0);

	localparam [2:0]
		IDLE = 3'b000,
		WAIT_DATA = 3'b001
		RECV = 3'b011,
		SEND = 3'b010,
		CRC_CHECK = 3'b110;
	reg [2:0] state = IDLE;

	reg [63:0] block = {64{1'bz}};
	assign ioblock = block;

	reg [4:0] counter = {5{1'b0}};

	always @(posedge iclk)
	begin
		if(irst == 1'b1)
		begin
			state = IDLE;
		end
		else
		begin
			case(state)
				IDLE:
				begin
					if(start)
					begin
						if(isend_rcv == 1'b0)
							state <= RECV;
						else
						begin
							state <= SEND;
						end
					end
				end
				WAIT_DATA:
				begin
				end
				RECV:
				begin
				end
				SEND:
				begin
				end
				CHECK_CRC
				begin
				end
			endcase
		end
	end

endmodule
