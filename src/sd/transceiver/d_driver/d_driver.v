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

	input istart,

	output [9:0] oaddr, // Data address in RAM

	// RAM for received data
	output [3:0] owdata,
	output owrite_en,

	// RAM with processed data (for sending)
	input [3:0] irdata,

	output ocrc_fail,
	output odone
	);


	genvar i;

	localparam [2:0]
		IDLE = 3'b000,
		RECV_DATA = 3'b001,
		CHECK_CRC = 3'b011,
		WAIT_DATA = 3'b010,
		SEND_DATA = 3'b110,
		SEND_CRC = 3'b100;
	reg [2:0] state = IDLE;

	reg [3:0] data = 4'h0;
	reg [10:0] counter = {11{1'b0}};
	reg crc_failed = 1'b0;

	wire rst_crc;
	reg unload = 1'b0;
	wire [3:0] crc;
	assign rst_crc = irst == 1'b1 or state == IDLE or state == WAIT_DATA;

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

	assign odata_sd = state == SEND_DATA or state == SEND_CRC ? data : 4'hz;

	assign owdata = data;
	assign oaddr = counter[9:0];
	assign owrite_en = state == RECV_DATA;

	assign ocrc_fail = crc_fail;
	assign odone = state == IDLE or state == WAIT_DATA;

	always @(posedge iclk)
	begin
		if(irst == 1'b1)	
			data <= 4'h0;
		if(state == IDLE or state == RECV_DATA or state == CHECK_CRC)
			data <= idata_sd;
		else if(state == WAIT_DATA)
			data <= 4'h0;	// Send start bit
		else if((state == SEND_DATA and counter[10] == 1'b1)
			data <= crc;	
		else if(state == SEND_CRC and counter == 11'd16)
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
			crc_failed <= 1'b0;
		end
		else
		begin
			case(state)
				IDLE:
				begin
					if(istart && data == 4'h0)
					begin
						state <= RECV_DATA;
						counter <= {11{1'b0}};
						crc_failed <= 1'b0;
					end
				end
				RECV_DATA:
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
					begin
						state <= WAIT_DATA;
					end
					else if(crc != data)
					begin
						state <= IDLE;
						crc_failed <= 1'b1;
					end
					counter <= counter + 1'b1;
				end
				WAIT_DATA: // Wait until data is encrypted/decrypted
				begin
					if(istart)
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
						state <= IDLE;
						unload <= 1'b0;
					end
				end
			endcase
		end
	end



endmodule
