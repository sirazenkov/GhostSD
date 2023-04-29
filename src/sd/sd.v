//===============================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: SD Bus controller
//===============================

module sd
#(
  parameter RAM_BLOCKS = 8
)(
  input irst, // Global reset
  input iclk, // System clock (36 MHz)
  
  input istart, // Start SD card initialization

  output osel_clk, // Select used clock

  // SD Bus
  input        icmd_sd,  // CMD line
  output       ocmd_sd,
  output       ocmd_sd_en,
  
  input  [3:0] idata_sd, // D line
  output [3:0] odata_sd,
  output       odata_sd_en,

  // OTP generator
  output ogen_otp,   // Generate next block of the pad
  output onew_otp,   // Start new one-time pad
  input  iotp_ready, // One-time pad block ready

  // RAM blocks
  output [$clog2(RAM_BLOCKS)-1:0] osel_ram, // Select RAM block

  output [9:0] oaddr,  // Data address in RAM
  input  [3:0] irdata, // RAM with processed data (for sending)
  output [3:0] owdata, // RAM for received data
  output       owrite_en,

  output osuccess, // SD-card encrypted/decrypted
  output ofail
);

  wire start_cmd, cmd_done;
  wire status_d, start_d, check_status, read_done, write_done;
  wire [5:0]  index;
  wire [31:0] arg;
  wire [75:0] resp;

  sd_fsm #(
    .RAM_BLOCKS(RAM_BLOCKS)
  ) sd_fsm_inst (
    .irst(irst),
    .iclk(iclk),

    .istart(istart),

    .icheck_status (check_status),
    .iread_done    (read_done),
    .iwrite_done   (write_done),

    .osel_clk(osel_clk),

    .ogen_otp  (ogen_otp),
    .onew_otp  (onew_otp),
    .iotp_ready(iotp_ready),
    
    .ostart_cmd(start_cmd),
    .oindex    (index),
    .oarg      (arg),
    .icmd_done (cmd_done),
    .iresp     (resp),
    
    .ostatus_d(status_d),
    .ostart_d (start_d),

    .ofail   (ofail),
    .osuccess(osuccess)
  );

  // CMD line driver
  cmd_driver cmd_driver_inst (
    .irst(irst),
    .iclk(iclk),

    .icmd_sd(icmd_sd),
    .ocmd_sd(ocmd_sd),
    .ocmd_sd_en(ocmd_sd_en),

    .istart(start_cmd),

    .icmd_index(index),
    .icmd_arg  (arg),

    .oresp(resp),

    .odone(cmd_done)
  );
  
  // D lines driver
  d_driver #(
    .RAM_BLOCKS(RAM_BLOCKS)
  ) d_driver_inst (
    .irst(irst),
    .iclk(iclk),

    .idata_sd   (idata_sd),
    .odata_sd   (odata_sd),
    .odata_sd_en(odata_sd_en),

    .istatus(status_d),
    .istart (start_d),

    .osel_ram (osel_ram),
    .oaddr    (oaddr),
    .owdata   (owdata),
    .owrite_en(owrite_en),
    .irdata   (irdata),

    .ocheck_status(check_status),
    .oread_done (read_done),
    .owrite_done(write_done)
  );

endmodule
