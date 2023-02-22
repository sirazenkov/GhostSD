//=======================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: CRC (cyclic redundancy check) with x^7 + x^3 + 1 polynomial
//========================================================================

module crc7 (
  input irst,
  input iclk,

  input idata,

  input  iunload,  // Shift out the CRC
  output ocrc  
);

  reg [6:0] crc;

  wire main_xor;

  integer i;

  assign main_xor = idata ^ crc[6];

  always @(posedge iclk) begin
    if (irst)
      crc <= 7'b0;
    else begin
      for(i = 0; i < 7; i = i + 1) begin
	if (iunload) begin
          if (i == 0)
	    crc[i] <= 1'b0;
          else
	    crc[i] <= crc[i-1];
        end else begin
          if (i == 0) 
            crc[i] <= main_xor;
          else if (i == 3 && ~iunload)
            crc[i] <= main_xor ^ crc[i-1];
          else
            crc[i] <= crc[i-1];
        end
      end
    end
  end 

  assign ocrc = crc[6];

endmodule

