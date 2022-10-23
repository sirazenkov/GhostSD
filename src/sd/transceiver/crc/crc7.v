//=======================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: CRC (cyclic redundancy check) with x^7 + x^3 + 1 polynomial
//========================================================================

module crc7 is
	(
	input idata,
    	input iclk,
	input irst,
	output [6:0] ocrc	
	);

	reg [6:0] crc;
	wire main_xor;

	assign main_xor = idata ^ crc[6];

	always @(posedge iclk) begin
		if(irst == 1'b1)
			crc <= (others => 1'b0);
		else begin
			for(i = 0; i < 7; i = i + 1) begin
				if(i == 0) 
					crc[i] <= main_xor;
				else if(i == 3)
					crc[i] <= main_xor ^ crc[i-1];
				else
					crc[i] <= crc[i-1];
			end
		end
	end 

	assign ocrc = crc;
endmodule
