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

  output reg osuccess, // SD-card encrypted/decrypted
  output reg ofail
);

  localparam [5:0]
    IDLE   = 6'd0,
    CMD55  = 6'd55,
    ACMD41 = 6'd41,
    CMD2   = 6'd2,
    CMD3   = 6'd3,
    CMD7   = 6'd7,
    ACMD6  = 6'd6,
    CMD17  = 6'd17,
    READ   = 6'd19, 
    CMD24  = 6'd24,
    WRITE  = 6'd20,
    CMD15  = 6'd15;

  reg [5:0] state, next_state;
  always @(posedge iclk)
    state <= irst ? IDLE : next_state;

  reg [31:0] arg;
  reg [22:0] addr_sd = 23'd0;
  
  always @(posedge iclk) begin
    if (irst)
      addr_sd <= 23'd0;
    else if (state == WRITE && next_state == CMD17)
      addr_sd <= addr_sd + 1'b1;
    else if (next_state == CMD15)
      addr_sd <= 23'd0;
  end

  always @(*) begin
    arg = {32{1'b1}};
    if (state == CMD55 && !sel_clk)
      arg[31:16] = {16{1'b0}};
    else if (state == ACMD41) begin
      arg        = 32'd0;
      arg[21:20] = 2'b11;
      arg[31]    = 1'b1;
    end
    else if (state == CMD7 || (state == CMD55 && sel_clk) || state == CMD15)
      arg[31:16] = rca;
    else if (state == ACMD6)
      arg[0] = 1'b0;
    else if (state == CMD17 || state == CMD24) begin
      arg[8:0]  = 9'd0;
      arg[31:9] = addr_sd;
    end
  end

  reg sel_clk = 1'b0;
  wire data_done, data_crc_fail, cmd_done;
  wire [31:0] resp;

  always @(*) begin
    next_state = state;
    if (istart && state == IDLE)
      next_state = CMD55;
    else if (data_done) begin
      if (state == READ) begin
        if (data_crc_fail)
          next_state = CMD17;
        else if (iotp_ready)
          next_state = CMD24;
      end
      else if (state == WRITE)
        next_state = CMD17;
    end
    else if (cmd_done) begin
      next_state = CMD24;
      case(state)
        CMD55:  next_state = resp[5] ? ((!sel_clk) ? ACMD41 : ACMD6) : IDLE;
        ACMD41: next_state = resp[31] & (resp[21] | resp[20]) ? CMD2 : IDLE;
        CMD2:   next_state = CMD3;
        CMD3:   next_state = CMD7;
        CMD7:   next_state = CMD55;
        ACMD6:  next_state = resp[12:9] == 4'd4 ? READ : IDLE;
        CMD17:  next_state = resp[31] ? CMD15 : READ;
        CMD24:  next_state = WRITE;
        CMD15:  next_state = IDLE;
      endcase
    end
  end

  reg [15:0] rca = 16'd0;

  always @(posedge iclk) begin
    if (irst)
      sel_clk <= 1'b0;
    else if (next_state == IDLE)
      sel_clk <= 1'b0;
    else if (next_state == CMD7)
      sel_clk <= 1'b1;
  end

  always @(posedge iclk) begin
    if (irst)
      rca <= 16'd0;
    else if (next_state == CMD7)
      rca <= resp[31:16];
  end

  always @(posedge iclk) begin
    if (irst) begin
      osuccess <= 1'b0;
      ofail    <= 1'b0;
    end
    else if (istart) begin
      osuccess <= 1'b0;
      ofail    <= 1'b0;
    end
    else if (next_state == IDLE) begin
      if (state == CMD15)
        osuccess <= 1'b1;
      else if (state != IDLE)
        ofail <= 1'b1;
    end
  end

  reg start_cmd;
  always @(posedge iclk) begin
    if (irst)
      start_cmd <= 1'b0;
    else 
      start_cmd <= (state != next_state
        && next_state != IDLE
        && next_state != READ
        && next_state != WRITE) ? 1'b1 : 1'b0;
  end

  wire start_d;
  reg  start_d_read, start_d_write;
  always @(posedge iclk) begin
    if (irst) begin
      start_d_read  <= 1'b0;  
      start_d_write <= 1'b0;  
    end
    else if (state != next_state) begin
      if (next_state == CMD17)
        start_d_read  <= 1'b1;
      if (next_state == WRITE)
        start_d_write <= 1'b1;
    end
    else begin
      start_d_read  <= 1'b0;
      start_d_write <= 1'b0;
    end
  end
  assign start_d  = start_d_write | start_d_read;
  assign ogen_otp = state == READ;
  assign onew_otp = state == IDLE;

  transceiver transceiver_inst (
    .irst (irst),
    .iclk (iclk),

    .icmd_sd  (icmd_sd),
    .ocmd_sd  (ocmd_sd),
    .idata_sd (idata_sd),
    .odata_sd (odata_sd),
    .oclk_sd  (oclk_sd),

    .isel_clk (sel_clk),

    .icmd_index (state),
    .icmd_arg   (arg), 
    .oresp      (resp),

    .oaddr     (oaddr),
    .owdata    (owdata),
    .owrite_en (owrite_en),
    .irdata    (irdata),

    .istart_d       (start_d),
    .odata_crc_fail (data_crc_fail),
    .odata_done     (data_done),

    .istart_cmd (start_cmd),
    .ocmd_done  (cmd_done)
  );  

endmodule

