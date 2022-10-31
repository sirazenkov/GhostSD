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

	output [0:31] oresp,	// Received response
	output ocrc_failed,	// Response's CRC check failed
	output odone		// Operation done
	);


	wire rst_crc;
	wire crc;
	
	assign rst_crc = irst | (counter == 8'h00);

	crc7 crc7_inst
	(
		.irst(rst_crc),
		.iclk(iclk),
		.idata(),
		.ocrc(crc)
	);

	localparam [:]
		IDLE = ,
		PREP_CMD = ,
		SEND_CMD = ,
		RCV_RESP = ,
		FINISH = ; // Send GO_INACTIVE_STATE (CMD15) command

	reg [7:0] counter = 8'h00;
	reg [0:39] cmd_content = {0'b0, 0'b1, 38{1'b0}};

	always @(posedge iclk) begin
		if(irst == 1'b1)
		begin 
			current_state = IDLE;
                        odone <= 1'b0;
			counter <= 8'h00;
		end
		else
		begin
                        case(current_state)
				IDLE :  
				begin
					if(isend == 1'b1)
					begin
						current_state <= SEND_CMD;
						cmd_content <= {1'b0, 1'b1, icmd_index, icmd_arg};
					end
				end
				SEND_CMD :
				begin	
					counter <= counter + 1'b1;
					if(counter < 40)
					begin
						iocmd_sd <= cmd_content[0];
						cmd_content <= {cmd_content[1:39], 1'b0};
					end	
					else if (counter == 40) 
					begin

					end
						current_state <= (icmd_index == 6'd15) ? FINISH : SEND_CMD;
				end
                                RCV_RESP : 

					counter <= 8'h00;
				FINISH :
                                default : current_state <= IDLE;
                        end case;
		end
        end
endmodule
