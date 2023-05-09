//==============================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: Clock divider for generating fast and slow SD clocks without PLLs
//==============================================================================

module clock_divider (
  input irst,      // Global reset
  input iclk,      // Reference clock
  input isel_clk,  // Select slow (0) or fast (1) clock
  output oclk_otp,
  output oclk_sd
);

  reg [6:0] counter = 7'd0; 
  always @(posedge iclk or posedge irst) begin
    if (irst)
      counter <= 7'd0;
    else
      counter <= counter + 1'b1;  
  end

  assign oclk_sd  = isel_clk ? iclk : counter[6];
  assign oclk_otp = iclk;

endmodule
