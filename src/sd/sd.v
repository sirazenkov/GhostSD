//==========================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: SD Bus protocol communication
//==========================================

module sd
	(
	input irst,
	input iclk, // System clock (36 MHz)

	input istart,
	input iaction,	// 0- encrypt, 1 - decrypt

	output [:] oresponse,
	output [3:0] oblock,
	output ovalid
	);


endmodule
