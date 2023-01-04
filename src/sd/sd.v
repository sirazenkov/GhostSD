//==========================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: SD Bus protocol communication
//==========================================

module sd
	(
	input irst,
	input iclk, // System clock (36 MHz)

	// SD Bus
	input icmd_sd,		// CMD line
	output ocmd_sd,
	input [3:0] idata_sd,	// D line
	output [3:0] odata_sd,
	output oclk_sd,		// CLK line

	input istart,

	input iread,		// Read next block from SD card
	input iwrite,		// Write processed block

	output [9:0] oaddr, 	// Data address in RAM

        // RAM for received data
        output [3:0] owdata,
        output owrite_en,

        // RAM with processed data (for sending)
        input [3:0] irdata,

	output reg osuccess,	// SD-card encrypted/decrypted
	output reg ofail
	);

	localparam [5:0]
		IDLE = 6'd0,
		CMD55 = 6'd55,
		ACMD41 = 6'd41,
		CMD2 = 6'd2,
		CMD3 = 6'd3,
		CMD7 = 6'd7,
		ACMD6 = 6'd6,
		WAIT = 6'd1,
		CMD17 = 6'd17,
		CMD24 = 6'd24,
		CMD15 = 6'd15;

	reg state;
	wire next_state;
	always_ff @(posedge iclk) begin
		if(irst)
			state <= IDLE;
		else
			state <= next_state;
	end

	always @(*) begin
		next_state = state;
		if(istart && state == IDLE)
			next_state == CMD55;
		else if(iread && state == WAIT)
			next_state = CMD17;
		else if(valid_resp) begin
			next_state = CMD24;
			case(state)
				CMD55:
					if(response[5]) begin
						if(sel_clk == 1'b0)
							next_state = ACMD41;
						else
							next_state = ACMD6;
					end
					else
						next_state = IDLE;
				ACMD41:
					if(resp[31] & (response[21] | response[20]))
						next_state = CMD2;
					else
						next_state = IDLE;
				CMD2:
					next_state = CMD3;
				CMD3:
					next_state = CMD7;
				CMD7:
					next_state = CMD55;
				ACMD6:
					next_state = WAIT;
				CMD17: begin
					if(response[31])
						next_state = CMD15;
					else if(iwrite)
						next_state = CMD24;
				end
				CMD24:
					next_state = WAIT;
				CMD15:
					next_state = IDLE;
			endcase
	end

	reg sel_clk = 1'b0;
	reg [15:0] rca = 16'd0;
	always_ff @(posedge iclk) begin
		if(irst) begin
			osuccess <= 1'b0;
			ofail <= 1'b0;
			sel_clk <= 1'b0;
			rca <= 16'd0;
		end
		else if(state == IDLE) begin
			osuccess <= 1'b0;
			ofail <= 1'b0;
		end
		else if(next_state == CMD7) begin
			sel_clk <= 1'b1;
			rca <= response[31:16];
		end
		else if(next_state == IDLE) begin
			sel_clk <= 1'b0;
			if(state == CMD15)
				osuccess <= 1'b1;
			else
				ofail <= 1'b1;
		end
	end

	reg start;
	always_ff @(posedge iclk) begin
		if(irst)
			start <= 1'b0;
		else if(state != next_state)
			start <= 1'b1;
		else
			start <= 1'b0;

endmodule
