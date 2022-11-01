//=======================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: CMD line driver
//========================================================================

module cmd_driver
	(
	input irst,		// Global reset
	input iclk,		// System clock

	inout iocmd_sd,		// CMD line

	input isend,		// Send command

	input [5:0] icmd_index,	// Command index
	input [31:0] icmd_arg,	// Command argument	

	output [119:0] oresp,	// Received response
	output ocrc_failed,	// Response's CRC check failed
	output odone		// Operation done
	);

	wire rst_crc;
	reg unload = 1'b0;
	wire crc;
	
	assign rst_crc = irst | (counter == 8'h00);

	crc7 crc7_inst
	(
		.irst(rst_crc),
		.iclk(iclk),
		.idata(iocmd_sd),
		.ocrc(crc),
		.iunload(unload)
	);

	localparam [:]
		IDLE = ,
		SEND_CMD = ,
		SEND_CRC = ,
		WAIT_RESP = ,
		RCV_RESP = ,
		RCV_CRC = ,

	reg [:] state = IDLE;

	reg [7:0] counter = 8'h00;
	reg [119:0] cmd_content = {120{1'b0}};
	reg [5:0] cmd_index = {6{1'b0}};

	always @(posedge iclk) begin
		if(irst == 1'b1)
		begin 
			state <= IDLE;
			counter <= 8'h00;
			cmd_content <= {120{1'b0}};

			ocrc_failed <= 1'b0;
		end
		else
		begin
                        case(state)
				IDLE :  
				begin
					if(isend == 1'b1)
					begin
						state <= SEND_CMD;
						cmd_content <= {1'b0, 1'b1, icmd_index, icmd_arg, 80{1'b0}};
						cmd_index <= icmd_index;
						counter <= 8'd40;
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
						counter <= 8'd7;
					end
				end
				SEND_CRC : 
				begin
					counter <= counter - 1'b1;
					if(counter == 8'h01)
						if(cmd_index == 6'd15)
							state <= IDLE;
						else
						begin
							state <= WAIT_RESP;
						end
				end
				WAIT_RESP : 
					if(iocmd == 1'b0)
						counter <= (cmd_index == 6'd2 || cmd_index == 6'd9) ? 
					8'd121 : 8'd33;
						state <= RCV_RESP;
				RCV_RESP :
				begin
					counter <= counter - 1'b1;
					cmd_content <= {cmd_content[118:0], iocmd_sd};
					if(counter == 8'h01)
					begin
						counter <= 8'd7;
						state <= RCV_CRC;
					end
				end
				RCV_CRC :
				begin
					if(iocmd != crc)
					begin
						ocrc_failed <= 1'b1;
						state <= IDLE;
					end
				end	
                                default : state <= IDLE;
                        end case;
		end
        end

	assign iocmd_sd = (state == SEND_CMD) ? cmd_content[119] : 
			(state == SEND_CRC) ? ((counter > 8'h00) ? crc : 1'b1) : 1'bz;
	assign oresp = resp_content;
	assign odone = state == IDLE;

endmodule
