//===============================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: D lines driver
//===============================

module d_driver
	(
	input irst, // Global reset
	input iclk, // SD clock

	// D line
	input [3:0] idata_sd,
	output [3:0] odata_sd,

	input istart_read,
	input istart_write,

	output [9:0] oaddr, // Data address in RAM

	// RAM for received data
	output [3:0] owdata,
	output owrite_en,

	// RAM with processed data (for sending)
	input [3:0] irdata,

	output ocrc_fail,
	output odone
	);

	localparam [2:0]
		IDLE = 3'b000,
		WAIT_RCV = 3'b001,
		RCV_DATA = 3'b011,
		CHECK_CRC = 3'b010,
		WAIT_SEND = 3'b110,
		SEND_DATA = 3'b100,
		SEND_CRC = 3'b101,
		BUSY = 3'b111;
	reg [2:0] state = IDLE;

	reg [3:0] data = 4'h0;
	reg [10:0] counter = {11{1'b0}};
	reg crc_fail = 1'b0;

	wire rst_crc;
	reg unload = 1'b0;
	wire [3:0] crc;
	assign rst_crc = irst == 1'b1 || state == IDLE || state == WAIT_SEND || state == WAIT_RCV;

	genvar i;
	generate
		for(i = 0; i < 4; i = i + 1)
		begin
			crc16 crc16_inst
			(
			.irst(rst_crc),
			.iclk(iclk),

        		.idata(data[i]),

        		.iunload(unload),
			.ocrc(crc[i])
			);
		end
	endgenerate

	assign odata_sd = state == SEND_DATA || state == SEND_CRC ? data : 4'hF;

	assign owdata = data;
	assign oaddr = counter[9:0];
	assign owrite_en = state == RCV_DATA;

	assign ocrc_fail = crc_fail;
	assign odone = state == IDLE || state == WAIT_SEND;

	always @(posedge iclk)
	begin
		if(irst == 1'b1)	
			data <= 4'h0;
		if(state == IDLE || state == RCV_DATA || state == CHECK_CRC)
			data <= idata_sd;
		else if(istart_write && state == WAIT_SEND)
			data <= 4'h0;	// Send start bit
		else if(state == SEND_DATA && counter[10] == 1'b1)
			data <= crc;	
		else if(state == SEND_CRC && counter == 11'd16)
			data <= 4'hf;	// Send end bit
		else
			data <= irdata;
	end

	always @(posedge iclk)
	begin
		if(irst == 1'b1)
		begin
			state <= IDLE;
			counter <= {11{1'b0}};
			unload <= 1'b0;
			crc_fail <= 1'b0;
		end
		else
		begin
			case(state)
				IDLE:
				begin
					if(istart_read)
					begin
						state <= WAIT_RCV;
						counter <= {11{1'b0}};
						crc_fail <= 1'b0;
					end
				end
				WAIT_RCV:
				begin
					if(data == 4'h0)
						state <= RCV_DATA;
				end
				RCV_DATA:
				begin
					counter <= counter + 1'b1;
					if(counter[10] == 1'b1)
					begin
						state <= CHECK_CRC;
						counter <= {11{1'b0}};
						unload <= 1'b1;
					end
				end
				CHECK_CRC: // Check CRC on the data lines
				begin
					if(counter == 11'd16)
						state <= WAIT_SEND;
					else if(crc != data)
					begin
						state <= IDLE;
						crc_fail <= 1'b1;
					end
					counter <= counter + 1'b1;
				end
				WAIT_SEND: // Wait until data is encrypted/decrypted
				begin
					if(istart_write)
					begin
						state <= SEND_DATA;
						counter <= {11{1'b0}};
					end
				end
				SEND_DATA:
				begin
					counter <= counter + 1'b1;
					if(counter[10] == 1'b1)
					begin
						state <= SEND_CRC;
						unload <= 1'b1;
						counter <= {11{1'b0}};
					end
				end
				SEND_CRC:
				begin
					counter <= counter + 1'b1;
					if(counter == 16'd16)
					begin
						state <= BUSY;
						unload <= 1'b0;
					end
				end
				BUSY:
				begin
					if(idata_sd[0])		// SD card finished writing
						state <= IDLE;
				end
			endcase
		end
	end

endmodule
