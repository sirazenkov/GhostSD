//================================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: CRC (cyclic redundancy check) with x^16 + x^12 + x^5 + 1 polynomial
//================================================================================

module crc16 (
  input irst,
  input iclk,
  
  input idata,

  input  iunload,  // Shift out the CRC
  output ocrc
);

  reg [15:0] crc;

  wire main_xor;

  integer i;

  assign main_xor = idata ^ crc[15];

  always @(posedge iclk) begin
    if (irst)
      crc <= 16'd0;
    else begin
      for(i = 0; i < 16; i = i + 1) begin
	if (iunload) begin
	  if (i == 0)
	    crc[i] <= 1'b0;
          else
            crc[i] <= crc[i-1];
        end else begin
          if (i == 0)
            crc[i] <= main_xor;
          else if (i == 5 || i == 12)
            crc[i] <= main_xor ^ crc[i-1];
          else
            crc[i] <= crc[i-1];
        end
      end
    end
  end

  assign ocrc = crc[15];

endmodule

