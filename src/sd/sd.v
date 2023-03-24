//===============================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: SD Bus controller
//===============================

module sd (
  input irst, // Global reset
  input iclk, // System clock (36 MHz)
  
  input istart, // Start SD card initialization

  output osel_clk, // Select used clock

  // SD Bus
  input        icmd_sd,  // CMD line
  output       ocmd_sd,
  input  [3:0] idata_sd, // D line
  output [3:0] odata_sd,

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

    .osel_clk(osel_clk),

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

  // CMD line driver
  cmd_driver cmd_driver_inst (
    .irst(irst),
    .iclk(iclk),

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
    .iclk(iclk),

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

