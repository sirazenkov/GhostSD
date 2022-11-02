//=============================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: CRC16 (cyclic redundancy check) module testbench
//=============================================================

module crc16_tb;

	localparam PERIOD = 40;
	localparam HALF_PERIOD = PERIOD / 2;
	
	localparam CRC_LEN = 16;

	reg data, clk, rst = 1'b0, unload = 1'b0;
	wire crc;
	reg [CRC_LEN-1:0] crc_reg;

	integer i;

	always
	begin
		clk = 1'b1;
		#HALF_PERIOD;
		clk = 1'b0;
		#HALF_PERIOD;
	end

	always @(posedge clk)
		crc_reg <= {crc_reg[CRC_LEN-2:0], crc};

	crc16 uut(
		.idata(data),
		.iclk(clk),
		.irst(rst),
		.ocrc(crc), 
		.iunload(unload)
	);

	initial
	begin
		$dumpfile("work/wave.ocd");
		$dumpvars(0, crc16_tb);
	end

	initial
	begin
		$display("Starting CRC16 testbench...");

		// Reset
		#HALF_PERIOD;		
		rst = 1'b1;
		#PERIOD;		
		rst = 1'b0;

		data = 1'b1;

		// Passing 512 bytes of 0xFF
		#(PERIOD*(512*8));	
		
		unload = 1'b1;
                for(i = 0; i < CRC_LEN; i = i + 1)
                        #PERIOD;
		
		if(crc_reg != 16'h7FA1)
			$display("Wrong checksum!");
		
		// Reset
		#HALF_PERIOD;		
		rst = 1'b1;
		#PERIOD;		
		rst = 1'b0;

		$display("End of test");
		$finish;
	end
endmodule
