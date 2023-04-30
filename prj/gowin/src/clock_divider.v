//=================================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: Clock divider for generating fast and slow SD clocks with Gowin PLLs
//=================================================================================

module clock_divider (
  output orst,
  input iclk,      // Reference clock
  input isel_clk,  // Select slow (0) or fast (1) clock
  output oclk_otp,
  output oclk_sd
);

  wire pll_lock, clk_0p8M, slow_clk, fast_clk;

  assign orst = ~pll_lock;

  Gowin_rPLL rPLL_inst (
        .lock(pll_lock),
        .clkout(oclk_otp),  //output clkout
        .clkoutd(clk_0p8M), //output clkoutd
        .clkin(iclk)        //input clkin
    );

  Gowin_CLKDIV2 CLKDIV2_slow_inst (
        .clkout(slow_clk), //output clkout
        .hclkin(clk_0p8M), //input hclkin
        .resetn(pll_lock)  //input resetn
  );

  Gowin_CLKDIV2 CLKDIV2_fast_inst (
        .clkout(fast_clk), //output clkout
        .hclkin(oclk_otp), //input hclkin
        .resetn(pll_lock)  //input resetn
  );

  Gowin_DCS DCS_inst (
        .clkout(oclk_sd),                     //output clkout
        .clksel({2'b00, ~isel_clk, isel_clk}),//input [3:0] clksel
        .clk0(fast_clk),                      //input clk0
        .clk1(slow_clk),                      //input clk1
        .clk2(),                              //input clk2
        .clk3()                               //input clk3
    );

endmodule
