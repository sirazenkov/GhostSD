//=============================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: cmd_driver module testbench
//=============================================================

module cmd_driver_tb;

	localparam PERIOD = 40;
	localparam HALF_PERIOD = PERIOD / 2;
	
	reg clk, rst = 1'b0;

	always
	begin
		clk = 1'b1;
		#HALF_PERIOD;
		clk = 1'b0;
		#HALF_PERIOD;
	end

	cmd_driver uut(
	);

	initial
	begin
		$dumpfile("work/wave.ocd");
		$dumpvars(0, cmd_driver_tb);
	end

	initial
	begin
		$display("Starting cmd_driver testbench...");

		// Reset
		#HALF_PERIOD;		
		rst = 1'b1;
		#PERIOD;		
		rst = 1'b0;

		

		$display("End of test");
		$finish;
	end
endmodule
