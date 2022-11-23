//===============================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: Prefix adder with log2(WIDH) depth
//===============================================

module prefix_adder(iA, iB, osum);
	parameter LEVELS = 5;
	parameter WIDTH = 2 ** 5;
	input [WIDTH-1:0] iA;
	input [WIDTH-1:0] iB;
	output [WIDTH-1:0] osum;

	genvar i;
	generate
	for(i = 0; i < LEVELS; i = i + 1)
		gen_prop_cell gen_prop_cell_inst
		(
			
		);
	endgenerate
endmodule
