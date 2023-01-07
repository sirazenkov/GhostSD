//=================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: GOST round testbench
//=================================

`timescale 1ns / 1ns

module round_tb;

	localparam PERIOD = 40;
	localparam HALF_PERIOD = PERIOD / 2;

	reg clk, rst = 1'b0, start = 1'b0;
	wire done;
	
	reg [31:0] keys[0:30];
	reg [63:0] iblocks[0:30];
	reg [63:0] correct_oblocks[0:30];

	reg [31:0] round_key;
	reg [63:0] iblock, correct_oblock;
	wire [63:0] oblock;

	integer i = 1;

	round uut(
		.irst(rst),
		.iclk(clk),

		.istart(start),

		.iblock(iblock),
		.ikey(round_key),

		.oblock(oblock),
		.odone(done)
	);

	initial
        begin
                $dumpfile("work/wave.ocd");
                $dumpvars(0, round_tb);
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
		$display("Starting GOST round testbench...");

		$readmemh("data/keys.hex", keys);
		$readmemh("data/iblocks.hex", iblocks);
		$readmemh("data/correct_oblocks.hex", correct_oblocks);

		// Reset
		rst = 1'b1;
		#PERIOD;
		rst = 1'b0;
		
		for(i = 0; i < 31; i = i + 1)
		begin
			#PERIOD;
			round_key = keys[i];
			iblock = iblocks[i];
			correct_oblock = correct_oblocks[i];
			start = 1'b1;
			#PERIOD;

			@(done == 1'b1);
			if(oblock != correct_oblock) begin
				$display("Error: Round %d failed!", i);
				$finish;
			end
		end

		$display("Test passed");
		$finish;
	end
endmodule
