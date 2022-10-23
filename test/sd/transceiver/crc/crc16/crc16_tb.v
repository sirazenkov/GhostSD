//=============================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: CRC16 (cyclic redundancy check) module testbench
//=============================================================

module crc16_tb;

	localparam PERIOD = 40;
	localparam HALF_PERIOD = PERIOD / 2;

	reg data, clk, rst = 1'b0;
	wire [15:0] crc;

	always
	begin
		clk = 1'b1;
		#HALF_PERIOD;
		clk = 1'b0;
		#HALF_PERIOD;
	end

	crc16 uut(.idata(data), .iclk(clk), .irst(rst), .ocrc(crc));

	initial
	begin
		$dumpfile("work/wave.ocd");
		$dumpvars(0, crc16_tb);
	end

	initial
	begin
		// Reset
		#HALF_PERIOD;		
		rst = 1'b1;
		#PERIOD;		
		rst = 1'b0;

		data = 1'b1;

		// Passing 512 bytes of 0xFF
		#(PERIOD*(512*8));	
		if(crc != 16'h7FA1)
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
