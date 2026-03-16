//=====================================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@mail.tsu.ru
//description: Top module of GhostSD project for ICESugar-nano platform
//=====================================================================

module top (
  input irst,
  input iclk, // System clock

  // SD bus
  inout       iocmd_sd,  // CMD line
  inout [3:0] iodata_sd, // D[3:0] line
  output      oclk_sd,   // CLK line

  input rxd
);

  parameter RAM_BLOCKS = 8;

  reg  [31:0] iv;
  reg [256:0] key;
  reg         start;

  wire clk_sd;
  wire clk_otp;
  wire sel_clk_sd;

  uart_rx #(
    .DATA_WIDTH()
  ) uart_rx_inst (
    .clk(iclk),
    .rst(irst),

    .m_axis_tdata (),
    .m_axis_tvalid(),
    .m_axis_tready(),

    .rxd(rxd),

    .rx_busy         (),
    .rx_overrun_error(),
    .rx_frame_error  (),

    .prescale()
  );

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

    .istart     (start),

    .ikey       (key),
    .iiv        (iv),

    .iocmd_sd   (iocmd_sd),
    .iodata_sd  (iodata_sd),

    .osuccess   (osuccess),
    .ofail      (ofail)
  );

endmodule
