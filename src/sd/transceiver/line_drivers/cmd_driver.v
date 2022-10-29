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
	input ifinish,		// Send GO_INACTIVE_STATE (CMD15) command

	input [6:0] icmd_index,	// Command index
	input [31:0] icmd_arg,	// Command argument	

	output [0:135] oresp,	// Received response
	output ocrc_failed,	// Response's CRC check failed
	output odone		// Operation done
	);

	localparam
		IDLE = ,
		CMD_RESP = ,
		FINISH = ,
		DONE = ;

	always @(posedge iclk) begin
		if(irst == 1'b1)
		begin 
                        odone <= 1'b0;
                        cmd_bit_counter <= 'b0;
		end
		else
		begin
                        case(current_state)
                                IDLE :  if(istart_transaction == 1'b1) then
						current_state <= (icmd_index == 6'd0) ?  BARE_CMD : CMD_RESP;
                                BARE_CMD : 
                                CMD_RESP : 
                                default : current_state <= IDLE;
                        end case;
		end
        end
endmodule
