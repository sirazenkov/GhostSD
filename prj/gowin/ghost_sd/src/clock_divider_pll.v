//=================================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: Clock divider for generating fast and slow SD clocks with Gowin PLLs
//=================================================================================

module clock_divider_pll (
  input iclk,      // Reference clock
  input isel_clk,  // Select slow (0) or fast (1) clock
  output olocked,  // PLL locked
  output oclk_sd
);

  wire fast_clk, slow_clk;

  Gowin_rPLL rPLL_inst (
        .clkout(fast_clk),  //output clkout
        .lock(olocked),     //output lock
        .clkoutd(slow_clk), //output clkoutd
        .clkin(iclk)        //input clkin
    );

  Gowin_DCS DCS_inst (
        .clkout(oclk_sd),                     //output clkout
        .clksel({2'b00, ~isel_clk, isel_clk}), //input [3:0] clksel
        .clk0(fast_clk),                      //input clk0
        .clk1(slow_clk),                      //input clk1
        .clk2(),                              //input clk2
        .clk3()                               //input clk3
    );

endmodule
