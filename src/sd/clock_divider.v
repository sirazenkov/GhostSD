//=================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: Clock divider for generating fast and slow SD clocks
//=================================================================

module clock_divider (
  input irst,      // Global res
  input iclk,      // Reference clock
  output ofastclk, // Divided by 2 clock
  output oslowclk  // Divided by 128 clock
);

  reg [7:0] counter = 7'b0; 
  always @(posedge iclk or posedge irst) begin
    if (irst)
      counter <= 7'b0;
    else
      counter <= counter + 1'b1;  
  end

  assign ofastclk = counter[0];
  assign oslowclk = counter[6];

endmodule

