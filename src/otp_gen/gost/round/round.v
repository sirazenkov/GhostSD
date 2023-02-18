//============================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: GOST (Magma) block cipher round
//============================================

module round (
  input irst,
  input iclk,

  input [63:0] iblock,
  input [31:0] ikey,

  output [63:0] oblock
);

  wire [31:0] block_plus_key;
  wire [31:0] modified_block;

  assign block_plus_key = iblock[31:0] + ikey;
  assign modified_block = ((s_box_output << 11) | (s_box_output >> (32-11))) ^ iblock[63:32];

  wire [31:0] s_box_output;
  s_box s_box_inst (
    .iword(block_plus_key),
    .oword(s_box_output)
  );

  assign oblock = (iblock[31:0] << 32) | modified_block;

endmodule

