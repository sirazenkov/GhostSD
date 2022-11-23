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

	genvar i,j;
	wire [WIDTH:0] level_gen [0:LEVELS];
	wire [WIDTH:0] level_prop [0:LEVELS];
	assign level_gen[0] = {iA & iB, 1'b0};
	assign level_prop[0] = {iA | iB, 1'b0};

	generate
	for(i = 0; i < LEVELS; i = i + 1)
	begin
		for(j = 0; j <= WIDTH; j = j + 1)
		begin
			if(j / (2 ** i) % 2 == 1)
			begin
				gen_prop_cell gen_prop_cell_inst
				(
				.ileft_gen(level_gen[i][j]),
				.iright_gen(level_gen[i][(j / (2 ** i)) * (2 ** i) - 1]),
				.ileft_prop(level_prop[i][j]),
				.iright_prop(level_prop[i][(j / (2 ** i)) * (2 ** i) - 1]),
				.ogen(level_gen[i+1][j]),
				.oprop(level_prop[i+1][j])
				);
			end
			else
			begin
				assign level_gen[i+1][j] = level_gen[i][j];
				assign level_prop[i+1][j] = level_prop[i][j];
			end
		end
	end
	endgenerate

	assign osum = iA ^ iB ^ level_gen[LEVELS][WIDTH-1:0];
endmodule
