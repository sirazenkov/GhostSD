//=======================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: Top module of GhostSD project
//=======================================================================

module ghost_sd
	(
	input iclk, // 72 MHz system clock
	
	// SD lines
	inout iocmd_sd,		// CMD line
	inout [3:0] iodata_sd,	// D[3:0] line
	output oclk_sd,		// CLK line

	output status_led	// Blinking - running operation
				// OFF - failed
				// ON - success
	);

	gost gost_inst
	(
	
	);	

endmodule
