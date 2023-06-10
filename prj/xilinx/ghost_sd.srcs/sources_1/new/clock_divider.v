//=================================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: Clock divider for generating fast and slow SD clocks with Xilixn IP
//=================================================================================

module clock_divider (
  input irst,
  input iclk,      // Reference clock
  input isel_clk,  // Select slow (0) or fast (1) clock
  output oclk_otp,
  output oclk_sd
);

  wire slow_clk, fast_clk;

  clk_gen clk_gen_inst (
    .reset(irst),
    .iclk(iclk),
    .otp_clk(oclk_otp),
    .sd_fast_clk(fast_clk)
  );
  
  reg [6:0] counter = 7'd0; 
  always @(posedge fast_clk or posedge irst) begin
    if (irst)
      counter <= 7'd0;
    else
      counter <= counter + 1'b1;  
  end
  assign slow_clk = counter[6];
    
  BUFGMUX_CTRL BUFGMUX_CTRL_inst (
      .O(oclk_sd),
      .I0(slow_clk),
      .I1(fast_clk),
      .S(isel_clk)
   );

endmodule
