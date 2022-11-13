//==========================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: 4Kb RAM memory block (1024x4)
//==========================================

module ram (idin, iaddr, iwrite_en, iclk, odout);
	parameter addr_width = 10;
	parameter data_width = 4;
	input [addr_width-1:0] iaddr;
	input [data_width-1:0] idin;
	input iwrite_en, iclk;
	output [data_width-1:0] odout;

	reg [data_width-1:0] dout;
	reg [data_width-1:0] mem [(1<<addr_width)-1:0];

	always @(posedge iclk)
	begin
		if(iwrite_en)
			mem[iaddr] <= idin;
		odout <= mem[iaddr];
	end
endmodule
