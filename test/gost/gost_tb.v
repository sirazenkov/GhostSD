//=======================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: GOST (Magma) block cipher module testbench
//=======================================================

`timescale 1ns / 1ns

module gost_tb;

	localparam PERIOD = 40;
	localparam HALF_PERIOD = PERIOD / 2;

	reg clk, rst = 1'b0, start = 1'b0, enc_dec = 1'b0;
	wire done;
	
	reg [255:0] key = 256'hFFEEDDCCBBAA99887766554433221100F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF; 
	reg [63:0] iblock = {64{1'b0}};
	reg [63:0] plaintext = 64'hFEDCBA9876543210;
	reg [63:0] ciphertext = 64'h4EE901E5C2D8CA3D;
	wire [63:0] oblock;

	integer i;

	gost uut(
		.irst(rst),
		.iclk(clk),

		.istart(start),
		.ienc_dec(enc_dec),

		.ikey(key),
		.iblock(iblock),

		.oblock(oblock),
		.odone(done)
	);

	initial
        begin
                $dumpfile("work/wave.ocd");
                $dumpvars(0, gost_tb);
        end

	always
	begin
		clk = 1'b1;
		#HALF_PERIOD;
		clk = 1'b0;
		#HALF_PERIOD;
	end

	initial
	begin
		$display("Starting GOST testbench...");

		// Reset
		rst = 1'b1;
		#PERIOD;
		rst = 1'b0;
		#PERIOD;
		
		iblock = plaintext;
		start = 1'b1;
		#PERIOD;

		@(done == 1'b1);
		start = 1'b0;
		if(oblock != ciphertext)
			$display("Encryption failed!");
		#PERIOD;

		iblock = ciphertext;
		start = 1'b1;
		enc_dec = 1'b1;
		#PERIOD;

		@(done == 1'b1);
		start = 1'b0;
		if(oblock != plaintext)
			$display("Decryption failed!");
		#PERIOD;

		$display("End of test");
		$finish;
	end
endmodule
