//=================================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: Clock divider for generating fast and slow SD clocks with Gowin PLLs
//=================================================================================

module clock_divider (
  input irst,
  input iclk,      // Reference clock
  input isel_clk,  // Select slow (0) or fast (1) clock
  output oclk_otp,
  output oclk_sd
);

  wire fast_clk, slow_clk, slow_clk_div2;

  Gowin_rPLL rPLL_inst (
        .reset(irst),
        .clkout(oclk_otp),  //output clkout
        .clkoutd(slow_clk), //output clkoutd
        .clkoutd3(fast_clk),//output clkoutd3
        .clkin(iclk)        //input clkin
    );

  Gowin_CLKDIV CLKDIV_inst (
        .clkout(slow_clk_div2), //output clkout
        .hclkin(slow_clk),      //input hclkin
        .resetn(~irst)          //input resetn
  );

  Gowin_DCS DCS_inst (
        .clkout(oclk_sd),                     //output clkout
        .clksel({2'b00, ~isel_clk, isel_clk}),//input [3:0] clksel
        .clk0(fast_clk),                      //input clk0
        .clk1(slow_clk_div2),                 //input clk1
        .clk2(),                              //input clk2
        .clk3()                               //input clk3
    );

endmodule
