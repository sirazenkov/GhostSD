//=====================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@mail.tsu.ru
//description: Top module of GhostSD project for ICESugar-nano platform
//=====================================================================

module top (
  input irst,
  input iclk, // System clock

  input istart,

  // SD bus
  inout       iocmd_sd,  // CMD line
  inout [3:0] iodata_sd, // D[3:0] line
  output      oclk_sd,   // CLK line

  output osuccess,
  output ofail
);

  parameter KEY = 256'h34d20ac43f554f1d2fd101496787e3954e39d417e33528f13c005501aa1a9e47;
  parameter IV = 32'hb97b7f46;

  parameter RAM_BLOCKS = 8;

  wire clk_sd;
  wire clk_otp;
  wire sel_clk_sd;

  clock_divider clock_divider_inst (
    .irst    (irst),
    .iclk    (iclk),
    .isel_clk(sel_clk_sd),
    .oclk_sd (clk_sd)
  );

  SB_GB clk_sd_buf (
    .USER_SIGNAL_TO_GLOBAL_BUFFER(clk_sd),
    .GLOBAL_BUFFER_OUTPUT(oclk_sd)
  );
  SB_GB clk_otp_buf (
    .USER_SIGNAL_TO_GLOBAL_BUFFER(iclk),
    .GLOBAL_BUFFER_OUTPUT(clk_otp)
  );

  ghost_sd #(
    .RAM_BLOCKS(RAM_BLOCKS)
  ) ghost_sd_inst (
    .irst       (irst),
    .iclk_otp   (clk_otp),
    .iclk_sd    (oclk_sd),
    .osel_clk_sd(sel_clk_sd),

    .istart     (istart),

    .ikey       (KEY),
    .iiv        (IV),

    .iocmd_sd   (iocmd_sd),
    .iodata_sd  (iodata_sd),

    .osuccess   (osuccess),
    .ofail      (ofail)
  );

endmodule
