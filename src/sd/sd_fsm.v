//==================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: SD Bus controller FSM
//==================================

module sd_fsm (
  input irst,
  input iclk,

  input istart,
  input icmd_done,
  input [31:0] iresp,
  input idata_crc_fail,
  input idata_done,
  input iotp_ready,

  output reg osel_clk,
  output     ogen_otp,
  output     onew_otp,
  output reg ostart_cmd,
  output     [5:0] oindex,
  output reg [31:0] oarg,
  output reg ostart_d,
  output reg ofail,
  output reg osuccess
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

  assign oindex = state;

  reg [22:0] addr_sd;
  always @(posedge iclk) begin
    if (irst)
      addr_sd <= 23'd0;
    else if (state == WRITE && next_state == CMD17)
      addr_sd <= addr_sd + 1'b1;
    else if (next_state == CMD15)
      addr_sd <= 23'd0;
  end

  reg [15:0] rca;
  always @(posedge iclk) begin
    if (irst)
      rca <= 16'd0;
    else if (next_state == CMD7)
      rca <= iresp[31:16];
  end

  always @(*) begin
    oarg = {32{1'b1}};
    if (state == CMD55 && !osel_clk)
      oarg[31:16] = {16{1'b0}};
    else if (state == ACMD41) begin
      oarg        = 32'd0;
      oarg[21:20] = 2'b11;
      oarg[31]    = 1'b1;
    end
    else if (state == CMD7 || (state == CMD55 && osel_clk) || state == CMD15)
      oarg[31:16] = rca;
    else if (state == ACMD6)
      oarg[0] = 1'b0;
    else if (state == CMD17 || state == CMD24) begin
      oarg[8:0]  = 9'd0;
      oarg[31:9] = addr_sd;
    end
  end

  always @(*) begin
    next_state = state;
    if (istart && state == IDLE)
      next_state = CMD55;
    else if (idata_done) begin
      if (state == READ) begin
        if (idata_crc_fail)
          next_state = CMD17;
        else if (iotp_ready)
          next_state = CMD24;
      end
      else if (state == WRITE)
        next_state = CMD17;
    end
    else if (icmd_done) begin
      next_state = CMD24;
      case(state)
        CMD55:  next_state = iresp[5] ? ((!osel_clk) ? ACMD41 : ACMD6) : IDLE;
        ACMD41: next_state = iresp[31] & (iresp[21] | iresp[20]) ? CMD2 : IDLE;
        CMD2:   next_state = CMD3;
        CMD3:   next_state = CMD7;
        CMD7:   next_state = CMD55;
        ACMD6:  next_state = iresp[12:9] == 4'd4 ? READ : IDLE;
        CMD17:  next_state = iresp[31] ? CMD15 : READ;
        CMD24:  next_state = WRITE;
        CMD15:  next_state = IDLE;
      endcase
    end
  end

  always @(posedge iclk) begin
    if (irst)
      osel_clk <= 1'b0;
    else if (next_state == IDLE)
      osel_clk <= 1'b0;
    else if (next_state == CMD7)
      osel_clk <= 1'b1;
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

  always @(posedge iclk) begin
    if (irst)
      ostart_cmd <= 1'b0;
    else 
      ostart_cmd <= (state != next_state
        && next_state != IDLE
        && next_state != READ
        && next_state != WRITE) ? 1'b1 : 1'b0;
  end

  always @(posedge iclk) begin
    if (irst)
      ostart_d <= 1'b0;  
    else if (state != next_state) begin
      if (next_state == CMD17 || next_state == WRITE)
        ostart_d <= 1'b1;
    end else
      ostart_d <= 1'b0;
  end
  assign ogen_otp = state == READ;
  assign onew_otp = state == IDLE; 

endmodule

