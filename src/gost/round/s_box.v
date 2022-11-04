//=============================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: S-boxes for Magma cipher round
//=============================================

module s_box
	(
	input [31:0] iword,
	output [31:0] oword
	);

	always @(*)
	begin
		case(iword[31:28]) // substitution 7
			4'h0: oword[31:28] = 4'h1;
			4'h1: oword[31:28] = 4'h7;
			4'h2: oword[31:28] = 4'hE;
			4'h3: oword[31:28] = 4'hD;
			4'h4: oword[31:28] = 4'h0;
			4'h5: oword[31:28] = 4'h5;
			4'h6: oword[31:28] = 4'h8;
			4'h7: oword[31:28] = 4'h3;
			4'h8: oword[31:28] = 4'h4;
			4'h9: oword[31:28] = 4'hF;
			4'hA: oword[31:28] = 4'hA;
			4'hB: oword[31:28] = 4'h6;
			4'hC: oword[31:28] = 4'h9;
			4'hD: oword[31:28] = 4'hC;
			4'hE: oword[31:28] = 4'hB;
			4'hF: oword[31:28] = 4'h2;
		endcase

		case(iword[27:24]) // substitution 6
			4'h0: oword[27:24] = 4'h8;
			4'h1: oword[27:24] = 4'hE;
			4'h2: oword[27:24] = 4'h2;
			4'h3: oword[27:24] = 4'h5;
			4'h4: oword[27:24] = 4'h6;
			4'h5: oword[27:24] = 4'h9;
			4'h6: oword[27:24] = 4'h1;
			4'h7: oword[27:24] = 4'hC;
			4'h8: oword[27:24] = 4'hF;
			4'h9: oword[27:24] = 4'h4;
			4'hA: oword[27:24] = 4'hB;
			4'hB: oword[27:24] = 4'h0;
			4'hC: oword[27:24] = 4'hD;
			4'hD: oword[27:24] = 4'hA;
			4'hE: oword[27:24] = 4'h3;
			4'hF: oword[27:24] = 4'h7;
		endcase

		case(iword[23:20]) // substitution 5
			4'h0: oword[23:20] = 4'h5;
			4'h1: oword[23:20] = 4'hD;
			4'h2: oword[23:20] = 4'hF;
			4'h3: oword[23:20] = 4'h6;
			4'h4: oword[23:20] = 4'h9;
			4'h5: oword[23:20] = 4'h2;
			4'h6: oword[23:20] = 4'hC;
			4'h7: oword[23:20] = 4'hA;
			4'h8: oword[23:20] = 4'hB;
			4'h9: oword[23:20] = 4'h7;
			4'hA: oword[23:20] = 4'h8;
			4'hB: oword[23:20] = 4'h1;
			4'hC: oword[23:20] = 4'h4;
			4'hD: oword[23:20] = 4'h3;
			4'hE: oword[23:20] = 4'hE;
			4'hF: oword[23:20] = 4'h0;
		endcase

		case(iword[19:16]) // substitution 4
			4'h0: oword[19:16] = 4'h7;
			4'h1: oword[19:16] = 4'hF;
			4'h2: oword[19:16] = 4'h5;
			4'h3: oword[19:16] = 4'hA;
			4'h4: oword[19:16] = 4'h8;
			4'h5: oword[19:16] = 4'h1;
			4'h6: oword[19:16] = 4'h6;
			4'h7: oword[19:16] = 4'hD;
			4'h8: oword[19:16] = 4'h0;
			4'h9: oword[19:16] = 4'h9;
			4'hA: oword[19:16] = 4'h3;
			4'hB: oword[19:16] = 4'hE;
			4'hC: oword[19:16] = 4'hB;
			4'hD: oword[19:16] = 4'h4;
			4'hE: oword[19:16] = 4'h2;
			4'hF: oword[19:16] = 4'hC;
		endcase

		case(iword[15:12]) // substitution 3
			4'h0: oword[15:12] = 4'hC;
			4'h1: oword[15:12] = 4'h8;
			4'h2: oword[15:12] = 4'h2;
			4'h3: oword[15:12] = 4'h1;
			4'h4: oword[15:12] = 4'hD;
			4'h5: oword[15:12] = 4'h4;
			4'h6: oword[15:12] = 4'hF;
			4'h7: oword[15:12] = 4'h6;
			4'h8: oword[15:12] = 4'h7;
			4'h9: oword[15:12] = 4'h0;
			4'hA: oword[15:12] = 4'hA;
			4'hB: oword[15:12] = 4'h5;
			4'hC: oword[15:12] = 4'h3;
			4'hD: oword[15:12] = 4'hE;
			4'hE: oword[15:12] = 4'h9;
			4'hF: oword[15:12] = 4'hB;
		endcase

		case(iword[11:8]) // substitution 2
			4'h0: oword[11:8] = 4'hB;	
			4'h1: oword[11:8] = 4'h3;	
			4'h2: oword[11:8] = 4'h5;	
			4'h3: oword[11:8] = 4'h8;	
			4'h4: oword[11:8] = 4'h2;	
			4'h5: oword[11:8] = 4'hF;	
			4'h6: oword[11:8] = 4'hA;	
			4'h7: oword[11:8] = 4'hD;	
			4'h8: oword[11:8] = 4'hE;	
			4'h9: oword[11:8] = 4'h1;	
			4'hA: oword[11:8] = 4'h7;	
			4'hB: oword[11:8] = 4'h4;	
			4'hC: oword[11:8] = 4'hC;	
			4'hD: oword[11:8] = 4'h9;	
			4'hE: oword[11:8] = 4'h6;	
			4'hF: oword[11:8] = 4'h0;	
		endcase

		case(iword[7:4]) // substitution 1
			4'h0: oword[7:4] = 4'h6;
			4'h1: oword[7:4] = 4'h8;
			4'h2: oword[7:4] = 4'h2;
			4'h3: oword[7:4] = 4'h3;
			4'h4: oword[7:4] = 4'h9;
			4'h5: oword[7:4] = 4'hA;
			4'h6: oword[7:4] = 4'h5;
			4'h7: oword[7:4] = 4'hC;
			4'h8: oword[7:4] = 4'h1;
			4'h9: oword[7:4] = 4'hE;
			4'hA: oword[7:4] = 4'h4;
			4'hB: oword[7:4] = 4'h7;
			4'hC: oword[7:4] = 4'hB;
			4'hD: oword[7:4] = 4'hD;
			4'hE: oword[7:4] = 4'h0;
			4'hF: oword[7:4] = 4'hF;
		endcase

		case(iword[3:0]) // substitution 0
			4'h0: oword[3:0] = 4'hC;
			4'h1: oword[3:0] = 4'h4;
			4'h2: oword[3:0] = 4'h6;
			4'h3: oword[3:0] = 4'h2;
			4'h4: oword[3:0] = 4'hA;
			4'h5: oword[3:0] = 4'h5;
			4'h6: oword[3:0] = 4'hB;
			4'h7: oword[3:0] = 4'h9;
			4'h8: oword[3:0] = 4'hE;
			4'h9: oword[3:0] = 4'h8;
			4'hA: oword[3:0] = 4'hD;
			4'hB: oword[3:0] = 4'h7;
			4'hC: oword[3:0] = 4'h0;
			4'hD: oword[3:0] = 4'h3;
			4'hE: oword[3:0] = 4'hF;
			4'hF: oword[3:0] = 4'h1;
		endcase
	end

endmodule
