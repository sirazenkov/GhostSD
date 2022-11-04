//===============================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: CMD line driver
//===============================

module cmd_driver
	(
	input irst,		// Global reset
	input iclk,		// System clock

	inout iocmd_sd,		// CMD line

	input istart,		// Start transaction (command[-response])

	input [5:0] icmd_index,	// Command index
	input [31:0] icmd_arg,	// Command argument	

	output [119:0] oresp,	// Received response
	output odone		// Operation done
	);

	reg start_sh;
	wire start;
	always @(posedge iclk)
		start_sh <= istart;
	assign start = (istart == 1'b1) && (start_sh == 1'b0);

	wire rst_crc;
	reg unload = 1'b0;
	wire crc;
	
	assign rst_crc = irst | (counter == 8'h00);

	crc7 crc7_inst
	(
		.irst(rst_crc),
		.iclk(iclk),
		.idata(iocmd_sd),
		.iunload(unload),
		.ocrc(crc)
	);

	localparam [2:0]
		IDLE = 3'b000,
		SEND_CMD = 3'b001,
		SEND_CRC = 3'b011,
		WAIT_RESP = 3'b010,
		RCV_RESP = 3'b110,
		RCV_CRC = 3'b111;

	reg [2:0] state = IDLE;

	reg [7:0] counter = 8'h00;
	reg [119:0] cmd_content = {120{1'b0}};
	reg [5:0] cmd_index = {6{1'b0}};

	wire long_response = cmd_index == 6'd2 || cmd_index == 6'd9;

	reg crc_failed = 1'b0;

	always @(posedge iclk) begin
		if(irst == 1'b1)
		begin 
			state <= IDLE;

			counter <= 8'h00;
			cmd_index <= {6{1'b0}};
			cmd_content <= {120{1'b0}};
			crc_failed <= 1'b0;
		end
		else
		begin
                        case(state)
				IDLE : 
				begin
					if(start == 1'b1 || crc_failed == 1'b1)
					begin
						state <= SEND_CMD;

						counter <= 8'd40;
						cmd_index <= icmd_index;
						cmd_content <= {1'b0, 1'b1, icmd_index, icmd_arg, {80{1'b0}}};
						crc_failed <= 1'b0;
					end
				end
				SEND_CMD :
				begin	
					counter <= counter - 1'b1;
					cmd_content <= {cmd_content[118:0], 1'b0};
					if(counter == 8'b01)
					begin
						state <= SEND_CRC;
						unload <= 1'b1;
						counter <= 8'd8;
					end
				end
				SEND_CRC : 
				begin
					counter <= counter - 1'b1;
					if(counter == 8'h01)
					begin
						unload <= 1'b0;
						if(cmd_index == 6'd15)
							state <= IDLE;
						else
							state <= WAIT_RESP;
					end
				end
				WAIT_RESP : 
				begin
					if(iocmd_sd == 1'b0)
					begin
						counter <= long_response ? 8'd127 : 8'd39;
						state <= RCV_RESP;
					end
				end
				RCV_RESP :
				begin
					counter <= counter - 1'b1;
					cmd_content <= {cmd_content[118:0], iocmd_sd};
					if(counter == 8'h01)
					begin
						counter <= 8'd7;
						state <= RCV_CRC;
						unload <= 1'b1;
					end
				end
				RCV_CRC :
				begin
					counter <= counter - 1'b1;
					if(iocmd_sd != crc)
						crc_failed <= 1'b1;
					if(counter == 8'h01)
					begin
						unload <= 1'b0;
						state <= IDLE;
					end
				end
                                default : state <= IDLE;
                        endcase
		end
        end

	assign iocmd_sd = (state == SEND_CMD) ? cmd_content[119] : (
				(state == SEND_CRC) ?
					((counter > 8'h01) ?
						((counter > 8'd120) ? 1'b0 
						: crc) :
					1'b1) :
				1'bz);
	assign oresp = cmd_content;
	assign odone = (state == IDLE) && !(crc_failed);

endmodule
