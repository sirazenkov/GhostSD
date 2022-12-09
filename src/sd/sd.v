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

	// SD Bus
	input icmd_sd,		// CMD line
	output ocmd_sd,
	input [3:0] idata_sd,	// D line
	output [3:0] odata_sd,
	output oclk_sd,		// CLK line

	input istart,

	output [9:0] oaddr, // Data address in RAM

        // RAM for received data
        output [3:0] owdata,
        output owrite_en,

        // RAM with processed data (for sending)
        input [3:0] irdata,

	output [31:0] oresponse,
	output ovalid
	);


endmodule
