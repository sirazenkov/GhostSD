//==========================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: SD Bus protocol communication
//==========================================

module sd
	(
	input irst,		// Global reset
	input iclk, 		// System clock (36 MHz)

	// SD Bus
	input icmd_sd,		// CMD line
	output ocmd_sd,
	input [3:0] idata_sd,	// D line
	output [3:0] odata_sd,
	output oclk_sd,		// CLK line

	input istart,		// Start SD card encryption/decryption

	output ogen_otp,	// Generate next block of the pad
	input iotp_ready,	// One-time pad ready

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
		CMD17 = 6'd17,
		READ = 6'd19, 
		CMD24 = 6'd24,
		WRITE = 6'd20,
		CMD15 = 6'd15;

	reg state;
	wire next_state;
	always_ff @(posedge iclk) begin
		if(irst)
			state <= IDLE;
		else
			state <= next_state;
	end

	wire [31:0] arg;
	reg [22:0] addr_sd = 23'd0;
	
	always_ff @(posedge iclk) begin
		if(irst)
			addr_sd <= 23'd0;
		else if(state == WRITE && next_state == READ)
			addr_sd <= addr_sd + 1'b1;
		else if(next_state == CMD15)
			addr_sd <= 23'd0;
	end

	always @(*) begin
		arg = {32{1'b1}};
		if(state == CMD55 && !sel_clk)
			arg[31:16] = {16{1'b0}};
		else if(state == ACMD41) begin
			arg = 32'd0;
			arg[21:20] = 2'b11;
			arg[31] = 1'b1;
		end
		else if(state == CMD7 || (state == CMD55 && sel_clk) || state == CMD15)
			arg[31:16] = rca;
		else if(state == ACMD6)
			arg[0] = 1'b0;
		else if(state == CMD17 || state == CMD24) begin
			arg[8:0] = 9'd0;
			arg[31:9] = addr_sd;
		end
	end

	reg sel_clk = 1'b0;
	wire data_done, data_crc_fail, cmd_done;
	wire [31:0] resp;

	always @(*) begin
		next_state = state;
		if(istart && state == IDLE)
			next_state == CMD55;
		else if(state == READ && data_done) begin
			if(data_crc_failed)
				next_state = CMD17;
			else if(iwrite)
				next_state = CMD24;
		end
		else if(state == WRITE && data_done)
			next_state = CMD17;
		else if(cmd_done) begin
			next_state = CMD24;
			case(state)
				CMD55:
					if(resp[5]) begin
						if(sel_clk == 1'b0)
							next_state = ACMD41;
						else
							next_state = ACMD6;
					end
					else
						next_state = IDLE;
				ACMD41:
					if(resp[31] & (resp[21] | resp[20]))
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
					if(resp[12:9] == 4'd4)
						next_state = READ;
					else
						next_state = IDLE;
				CMD17: begin
					if(resp[31])
						next_state = CMD15;
					else if(iwrite)
						next_state = READ;
				end
				CMD24:
					next_state = WRITE;
				CMD15:
					next_state = IDLE;
			endcase
	end

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
			rca <= resp[31:16];
		end
		else if(next_state == IDLE) begin
			sel_clk <= 1'b0;
			if(state == CMD15)
				osuccess <= 1'b1;
			else
				ofail <= 1'b1;
		end
	end

	reg start_cmd;
	always_ff @(posedge iclk) begin
		if(irst)
			start_cmd <= 1'b0;
		else if(state != next_state
			&& next_state != IDLE
			&& next_state != READ
			&& next_state != WRITE)
			start_cmd <= 1'b1;
		else
			start_cmd <= 1'b0;

	reg start_d_read, start_d_write;
	always_ff @(posedge iclk) begin
		if(irst) begin
			start_d_read <= 1'b0;	
			start_d_write <= 1'b0;	
		end
		else if(state != next_state) begin
		       	if(next_state == CMD17)
				start_d_read <= 1'b1;
			if(next_state == WRITE)
				start_d_write <= 1'b1;
		end
		else begin
			start_d_read <= 1'b0;
			start_d_write <= 1'b0;
		end
	end
	assign ogen_otp = state == READ;

	transceiver transceiver_inst
        (
        	.irst(irst),
        	.iclk(iclk),

        	.icmd_sd(icmd_sd),
        	.ocmd_sd(ocmd_sd),
        	.idata_sd(idata_sd),
        	.odata_sd(odata_sd),
        	.oclk_sd(oclk_sd),

        	.isel_clk(sel_clk),

        	.icmd_index(state),
       		.icmd_arg(arg), 
        	.oresp(resp),

		.oaddr(oaddr),
        	.owdata(owdata),
        	.owrite_en(owrite_en),
        	.irdata(irdata),

		.istart_d_read(start_d_read),
		.istart_d_write(start_d_write),
		.oaddr_sd(addr_sd),
        	.odata_crc_fail(data_crc_fail),
        	.odata_done(data_done),

		.istart_cmd(start_cmd),
        	.ocmd_done(data_done)
        )	

endmodule
