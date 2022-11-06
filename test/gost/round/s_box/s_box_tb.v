//===================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: S-box module testbench
//===================================

`timescale 1ns / 1ns

module s_box_tb;

	localparam PERIOD = 40;

	reg [31:0] iword;
	wire [31:0] oword;

	integer i = 1;

	s_box uut(
		.iword(iword),
		.oword(oword)
	);

	initial
        begin
                $dumpfile("work/wave.ocd");
                $dumpvars(0, s_box_tb);
        end

	initial
	begin
		$display("Starting S-box testbench...");

		iword = 32'hFDB97531;
		#PERIOD;
		if(oword != 32'h2A196F34)
			$display("Test %d failed!", i);
		i = i + 1;

		iword = 32'h2A196F34;
		#PERIOD;
		if(oword != 32'hEBD9F03A)
			$display("Test %d failed!", i);
		i = i + 1;

		iword = 32'hEBD9F03A;
		#PERIOD;
		if(oword != 32'hB039BB3D)
			$display("Test %d failed!", i);
		i = i + 1;

		iword = 32'hB039BB3D;
		#PERIOD;
		if(oword != 32'h68695433)
			$display("Test %d failed!", i);

		$display("End of test");
		$finish;
	end
endmodule
