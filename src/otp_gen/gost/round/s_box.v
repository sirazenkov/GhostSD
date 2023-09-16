//===========================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: S-boxes for Magma cipher round
//===========================================
`timescale 1ns/100ps

module s_box (
  input  [31:0] iword,
  output [31:0] oword
);

  reg [31:0] word;
  assign oword = word;

  always @(*) begin
    case(iword[31:28]) // substitution 7
      4'h0: word[31:28] = 4'h1;
      4'h1: word[31:28] = 4'h7;
      4'h2: word[31:28] = 4'hE;
      4'h3: word[31:28] = 4'hD;
      4'h4: word[31:28] = 4'h0;
      4'h5: word[31:28] = 4'h5;
      4'h6: word[31:28] = 4'h8;
      4'h7: word[31:28] = 4'h3;
      4'h8: word[31:28] = 4'h4;
      4'h9: word[31:28] = 4'hF;
      4'hA: word[31:28] = 4'hA;
      4'hB: word[31:28] = 4'h6;
      4'hC: word[31:28] = 4'h9;
      4'hD: word[31:28] = 4'hC;
      4'hE: word[31:28] = 4'hB;
      4'hF: word[31:28] = 4'h2;
    endcase

    case(iword[27:24]) // substitution 6
      4'h0: word[27:24] = 4'h8;
      4'h1: word[27:24] = 4'hE;
      4'h2: word[27:24] = 4'h2;
      4'h3: word[27:24] = 4'h5;
      4'h4: word[27:24] = 4'h6;
      4'h5: word[27:24] = 4'h9;
      4'h6: word[27:24] = 4'h1;
      4'h7: word[27:24] = 4'hC;
      4'h8: word[27:24] = 4'hF;
      4'h9: word[27:24] = 4'h4;
      4'hA: word[27:24] = 4'hB;
      4'hB: word[27:24] = 4'h0;
      4'hC: word[27:24] = 4'hD;
      4'hD: word[27:24] = 4'hA;
      4'hE: word[27:24] = 4'h3;
      4'hF: word[27:24] = 4'h7;
    endcase

    case(iword[23:20]) // substitution 5
      4'h0: word[23:20] = 4'h5;
      4'h1: word[23:20] = 4'hD;
      4'h2: word[23:20] = 4'hF;
      4'h3: word[23:20] = 4'h6;
      4'h4: word[23:20] = 4'h9;
      4'h5: word[23:20] = 4'h2;
      4'h6: word[23:20] = 4'hC;
      4'h7: word[23:20] = 4'hA;
      4'h8: word[23:20] = 4'hB;
      4'h9: word[23:20] = 4'h7;
      4'hA: word[23:20] = 4'h8;
      4'hB: word[23:20] = 4'h1;
      4'hC: word[23:20] = 4'h4;
      4'hD: word[23:20] = 4'h3;
      4'hE: word[23:20] = 4'hE;
      4'hF: word[23:20] = 4'h0;
    endcase

    case(iword[19:16]) // substitution 4
      4'h0: word[19:16] = 4'h7;
      4'h1: word[19:16] = 4'hF;
      4'h2: word[19:16] = 4'h5;
      4'h3: word[19:16] = 4'hA;
      4'h4: word[19:16] = 4'h8;
      4'h5: word[19:16] = 4'h1;
      4'h6: word[19:16] = 4'h6;
      4'h7: word[19:16] = 4'hD;
      4'h8: word[19:16] = 4'h0;
      4'h9: word[19:16] = 4'h9;
      4'hA: word[19:16] = 4'h3;
      4'hB: word[19:16] = 4'hE;
      4'hC: word[19:16] = 4'hB;
      4'hD: word[19:16] = 4'h4;
      4'hE: word[19:16] = 4'h2;
      4'hF: word[19:16] = 4'hC;
    endcase

    case(iword[15:12]) // substitution 3
      4'h0: word[15:12] = 4'hC;
      4'h1: word[15:12] = 4'h8;
      4'h2: word[15:12] = 4'h2;
      4'h3: word[15:12] = 4'h1;
      4'h4: word[15:12] = 4'hD;
      4'h5: word[15:12] = 4'h4;
      4'h6: word[15:12] = 4'hF;
      4'h7: word[15:12] = 4'h6;
      4'h8: word[15:12] = 4'h7;
      4'h9: word[15:12] = 4'h0;
      4'hA: word[15:12] = 4'hA;
      4'hB: word[15:12] = 4'h5;
      4'hC: word[15:12] = 4'h3;
      4'hD: word[15:12] = 4'hE;
      4'hE: word[15:12] = 4'h9;
      4'hF: word[15:12] = 4'hB;
    endcase

    case(iword[11:8]) // substitution 2
      4'h0: word[11:8] = 4'hB;  
      4'h1: word[11:8] = 4'h3;  
      4'h2: word[11:8] = 4'h5;  
      4'h3: word[11:8] = 4'h8;  
      4'h4: word[11:8] = 4'h2;  
      4'h5: word[11:8] = 4'hF;  
      4'h6: word[11:8] = 4'hA;  
      4'h7: word[11:8] = 4'hD;  
      4'h8: word[11:8] = 4'hE;  
      4'h9: word[11:8] = 4'h1;  
      4'hA: word[11:8] = 4'h7;  
      4'hB: word[11:8] = 4'h4;  
      4'hC: word[11:8] = 4'hC;  
      4'hD: word[11:8] = 4'h9;  
      4'hE: word[11:8] = 4'h6;  
      4'hF: word[11:8] = 4'h0;  
    endcase

    case(iword[7:4]) // substitution 1
      4'h0: word[7:4] = 4'h6;
      4'h1: word[7:4] = 4'h8;
      4'h2: word[7:4] = 4'h2;
      4'h3: word[7:4] = 4'h3;
      4'h4: word[7:4] = 4'h9;
      4'h5: word[7:4] = 4'hA;
      4'h6: word[7:4] = 4'h5;
      4'h7: word[7:4] = 4'hC;
      4'h8: word[7:4] = 4'h1;
      4'h9: word[7:4] = 4'hE;
      4'hA: word[7:4] = 4'h4;
      4'hB: word[7:4] = 4'h7;
      4'hC: word[7:4] = 4'hB;
      4'hD: word[7:4] = 4'hD;
      4'hE: word[7:4] = 4'h0;
      4'hF: word[7:4] = 4'hF;
    endcase

    case(iword[3:0]) // substitution 0
      4'h0: word[3:0] = 4'hC;
      4'h1: word[3:0] = 4'h4;
      4'h2: word[3:0] = 4'h6;
      4'h3: word[3:0] = 4'h2;
      4'h4: word[3:0] = 4'hA;
      4'h5: word[3:0] = 4'h5;
      4'h6: word[3:0] = 4'hB;
      4'h7: word[3:0] = 4'h9;
      4'h8: word[3:0] = 4'hE;
      4'h9: word[3:0] = 4'h8;
      4'hA: word[3:0] = 4'hD;
      4'hB: word[3:0] = 4'h7;
      4'hC: word[3:0] = 4'h0;
      4'hD: word[3:0] = 4'h3;
      4'hE: word[3:0] = 4'hF;
      4'hF: word[3:0] = 4'h1;
    endcase
  end

endmodule

