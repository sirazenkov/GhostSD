//==========================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: SD Bus protocol communication
//==========================================

module sd (
  input irst, // Global reset
  input iclk, // System clock (36 MHz)
  
  input istart, // Start SD card initialization

  // SD Bus
  input        icmd_sd,  // CMD line
  output       ocmd_sd,
  input  [3:0] idata_sd, // D line
  output [3:0] odata_sd,
  output       oclk_sd,  // CLK line

  // OTP generator
  output ogen_otp,   // Generate next block of the pad
  output onew_otp,   // Start new one-time pad
  input  iotp_ready, // One-time pad block ready

  // RAM blocks
  output [9:0] oaddr,  // Data address in RAM
  input  [3:0] irdata, // RAM with processed data (for sending)
  output [3:0] owdata, // RAM for received data
  output       owrite_en,

  output osuccess, // SD-card encrypted/decrypted
  output ofail
);

  wire sel_clk;
  wire start_cmd, cmd_done;
  wire start_d, data_done, data_crc_fail;
  wire [5:0]  index;
  wire [31:0] resp, arg;

  sd_fsm sd_fsm_inst (
    .irst(irst),
    .iclk(iclk),

    .istart(istart),

    .idata_crc_fail(data_crc_fail),
    .idata_done    (data_done),

    .osel_clk(sel_clk),

    .ogen_otp  (ogen_otp),
    .onew_otp  (onew_otp),
    .iotp_ready(iotp_ready),
    
    .ostart_cmd(start_cmd),
    .oindex    (index),
    .oarg      (arg),
    .icmd_done (cmd_done),
    .iresp     (resp),
    
    .ostart_d(start_d),

    .ofail   (ofail),
    .osuccess(osuccess)
  );

  wire clk_18MHz, clk_281kHz, clk_sd;
  assign clk_sd  = sel_clk ? clk_18MHz : clk_281kHz;
  assign oclk_sd = clk_sd;

  // Get 18 Mhz and 281.25 kHz clocks from 36 MHz system clock
  clock_divider clock_divider_inst (
    .irst(irst),
    .iclk(iclk),

    .ofastclk(clk_18MHz),
    .oslowclk(clk_281kHz)
  );

  // CMD line driver
  cmd_driver cmd_driver_inst (
    .irst(irst),
    .iclk(clk_sd),

    .icmd_sd(icmd_sd),
    .ocmd_sd(ocmd_sd),

    .istart(start_cmd),

    .icmd_index(index),
    .icmd_arg  (arg),

    .oresp(resp),

    .odone(cmd_done)
  );
  
  // D lines driver
  d_driver d_driver_inst (
    .irst(irst),
    .iclk(clk_sd),

    .idata_sd(idata_sd),
    .odata_sd(odata_sd),

    .istart (start_d),

    .oaddr    (oaddr),
    .owdata   (owdata),
    .owrite_en(owrite_en),
    .irdata   (irdata),

    .ocrc_fail(data_crc_fail),
    .odone    (data_done)
  );

endmodule

