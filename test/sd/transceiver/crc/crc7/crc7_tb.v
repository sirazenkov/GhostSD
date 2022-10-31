//============================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: CRC7 (cyclic redundancy check) module testbench
//============================================================

`timescale 1ns / 1ns

module crc7_tb;

	localparam CMD0 = { 2'b01, 6'b000000, 32'b00000000000000000000000000000000 };	
	localparam CMD17 = { 2'b01, 6'b010001, 32'b00000000000000000000000000000000 };
	localparam RESP17 = { 2'b00, 6'b010001, 32'b00000000000000000000100100000000 };	

	localparam PERIOD = 40;
	localparam HALF_PERIOD = PERIOD / 2;
	
	localparam MSG_LEN = 40;
	localparam CRC_LEN = 7;

	reg data, clk, rst = 1'b0, unload = 1'b0;
	wire crc;
	reg [CRC_LEN-1:0] crc_reg;

	integer i;

	crc7 uut(
		.idata(data),
		.iclk(clk),
		.irst(rst),
		.iunload(unload),
		.ocrc(crc)
	);
	
	initial
        begin
                $dumpfile("work/wave.ocd");
                $dumpvars(0, crc7_tb);
        end

	always
	begin
		clk = 1'b1;
		#HALF_PERIOD;
		clk = 1'b0;
		#HALF_PERIOD;
	end

	always @(posedge clk)
	begin
		crc_reg <= {crc_reg[CRC_LEN-2:0], crc};
	end

	initial
	begin
		// Reset
		#HALF_PERIOD;		
		rst = 1'b1;
		#PERIOD;		
		rst = 1'b0;
		
		// Passing CMD0
		for(i = 0; i < MSG_LEN; i = i + 1)
		begin
			data = CMD0[MSG_LEN-1-i]; 
			#PERIOD;	
		end
		
		unload = 1'b1;
		for(i = 0; i < CRC_LEN; i = i + 1)
			#PERIOD;	
		unload = 1'b0;

		if(crc_reg != 7'b1001010)
			$display("Wrong CMD0 checksum!");
		
		// Reset
                rst = 1'b1;
                #PERIOD;
                rst = 1'b0;
		
		// Passing CMD17
		for(i = 0; i < MSG_LEN; i = i + 1)
		begin
			data = CMD17[MSG_LEN-1-i]; 
			#PERIOD;	
		end

		unload = 1'b1;
		for(i = 0; i < CRC_LEN; i = i + 1)
			#PERIOD;	
		unload = 1'b0;

		if(crc_reg != 7'b0101010)
			$display("Wrong CMD17 checksum!");

		// Reset
                rst = 1'b1;
                #PERIOD;
                rst = 1'b0;
		
		// Passing RESP17
		for(i = 0; i < MSG_LEN; i = i + 1)
		begin
			data = RESP17[MSG_LEN-1-i]; 
			#PERIOD;	
		end

		unload = 1'b1;
		for(i = 0; i < CRC_LEN; i = i + 1)
			#PERIOD;	
		
		if(crc_reg != 7'b0110011)
			$display("Wrong RESP17 checksum!");

		$display("End of test");
		$finish;
	end
endmodule
