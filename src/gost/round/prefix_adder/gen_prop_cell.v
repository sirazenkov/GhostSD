//=================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: Calculates generation and propagation bits for block
//=================================================================

module gen_prop_cell
	(
	input ileft_gen, iright_gen;
	input ileft_prop, iright_prop;
	output ogen, oprop;
	);

	assign ogen = (ileft_prop & iright_gen) | ileft_gen;
	assign oprop = ileft_prop & iright_prop;

endmodule
