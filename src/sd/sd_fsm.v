//==================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: SD Bus controller FSM
//==================================

module sd_fsm
#(
  parameter RAM_BLOCKS = 8
)(
  input irst,
  input iclk,

  input istart,
  input icmd_done,
  input [75:0] iresp,
  input iread_done,
  input icheck_status,
  input iwrite_done,
  input iotp_ready,

  output reg osel_clk    = 1'b0,
  output reg ogen_otp    = 1'b0,
  output     onew_otp,
  output reg ostart_cmd  = 1'b0,
  output     [5:0] oindex,
  output reg [31:0] oarg = 32'd0,
  output reg ostatus_d   = 1'b0,
  output reg ostart_d    = 1'b0,
  output reg ofail       = 1'b0,
  output reg osuccess    = 1'b0
);

  `ifdef COCOTB_SIM
     initial begin
       $dumpfile("wave.vcd");
       $dumpvars(0, sd_fsm);
       #1;
     end
  `endif

  reg start_reg = 1'b0;
  wire start;
  always @(posedge iclk or posedge irst) begin
    if (irst) start_reg <= 1'b0;
    else      start_reg <= istart;
  end
  assign start = istart & ~start_reg;

  localparam [5:0]
    IDLE   = 6'd0,
    CMD8   = 6'd8,
    CMD55  = 6'd55,
    ACMD41 = 6'd41,
    CMD2   = 6'd2,
    CMD3   = 6'd3,
    CMD9   = 6'd9,
    CMD7   = 6'd7,
    CMD6   = 6'd6,
    CMD18  = 6'd18,
    READ   = 6'd19,
    CMD12  = 6'd12,
    OTP    = 6'd20,
    ACMD23 = 6'd23,
    CMD25  = 6'd25,
    WRITE  = 6'd21,
    CMD13  = 6'd13,
    CMD15  = 6'd15;
  reg [5:0] state = IDLE, next_state;
  always @(posedge iclk or posedge irst) begin
    if (irst) state <= IDLE;
    else      state <= next_state;
  end

  assign oindex = state;

  reg [31-9-$clog2(RAM_BLOCKS):0] addr_sd = {(32-9-$clog2(RAM_BLOCKS)){1'b0}};
  always @(posedge iclk or posedge irst) begin
    if (irst)
      addr_sd <= {(32-9-$clog2(RAM_BLOCKS)){1'b0}};
    else if (state == WRITE && next_state == CMD12)
      addr_sd <= addr_sd + 1'b1;
    else if (state == CMD15)
      addr_sd <= {(32-9-$clog2(RAM_BLOCKS)){1'b0}};
  end

  reg [15:0] rca = 16'd0;
  always @(posedge iclk or posedge irst) begin
    if (irst)
      rca <= 16'd0;
    else if (state != next_state && state == CMD3)
      rca <= iresp[31:16];
  end

  reg [31-9-$clog2(RAM_BLOCKS):0] max_addr_sd = {(32-9-$clog2(RAM_BLOCKS)){1'b0}};
  always @(posedge iclk or posedge irst) begin
    if (irst)
      max_addr_sd <= {(32-9-$clog2(RAM_BLOCKS)){1'b0}};
    else if (state != next_state && state == CMD9)
      max_addr_sd <= (iresp[65:54]+1'b1) << (iresp[75:72]+iresp[41:39]+2-9-$clog2(RAM_BLOCKS));
  end

  reg switch = 1'b0;
  always @(posedge iclk or posedge irst) begin
    if (irst)
      switch <= 1'b0;
    else if (icmd_done && state == CMD6 && next_state == CMD6)
      switch <= 1'b1;
  end

  always @(*) begin
    oarg = {32{1'b1}};
    case (state)
      ACMD41: begin
        oarg        = 32'd0;
        oarg[21:20] = 2'b11;
        oarg[31]    = 1'b1;
      end
      CMD55, CMD9, CMD7, CMD13, CMD15: begin
        oarg[31:16] = rca;
        if (CMD13) oarg[15] = 1'b0;
      end
      CMD6: begin
        if (switch)
          oarg[30:1] = 30'd0;
        else
          oarg[0] = 1'b0;
      end
      ACMD23:
        oarg[22:0] = 23'd8;
      CMD18, CMD25: begin
        oarg[9+$clog2(RAM_BLOCKS)-1:0] = {(9+$clog2(RAM_BLOCKS)){1'b0}};
        oarg[31:9+$clog2(RAM_BLOCKS)]  = addr_sd;
      end
    endcase
  end

  wire tran_state;
  assign tran_state = iresp[12:9] == 4'd4;

  always @(*) begin
    next_state = state;
    if (start && state == IDLE)
      next_state = CMD55;
    else if (state == READ) begin
      if (iread_done || iwrite_done)
        next_state = CMD12;
    end
    else if (state == WRITE) begin
      if (iwrite_done)
        next_state = CMD12;
      else if (icheck_status)
        next_state = CMD13;
    end
    else if (state == OTP) begin
      if (iotp_ready)
        next_state = CMD55;
    end
    else if (icmd_done) begin
      case(state)
        CMD55:   next_state = iresp[5] ? ((~|rca) ? ACMD41 : iread_done ? ACMD23 : CMD6) : IDLE;
        ACMD41:  next_state = !(iresp[21] || iresp[20]) ? IDLE : (iresp[31] ? CMD2 : CMD55);
        CMD2:    next_state = CMD3;
        CMD3:    next_state = CMD9;
        CMD9:    next_state = CMD7;
        CMD7:    next_state = CMD55;
        CMD6:    next_state = switch ? CMD13 : (tran_state ? CMD6 : IDLE);
        CMD18:   next_state = iresp[31] ? CMD15 : READ;
        CMD12:   next_state = iwrite_done ? CMD13 : OTP;
        ACMD23:  next_state = CMD25;
        CMD25:   next_state = WRITE;
        CMD13:   next_state = iresp[8] ? (!iwrite_done && iresp[12:9] == 4'd6 ? WRITE : 
                              !tran_state ? CMD13 :
                              (addr_sd == max_addr_sd ? CMD15 : 
                              CMD18) ) : CMD13;
        default: next_state = IDLE;
      endcase
    end
  end

  always @(posedge iclk or posedge irst) begin
    if (irst)
      osel_clk <= 1'b0;
    else if (next_state == IDLE)
      osel_clk <= 1'b0;
    else if (next_state == CMD18)
      osel_clk <= 1'b1;
  end

  always @(posedge iclk or posedge irst) begin
    if (irst) begin
      osuccess <= 1'b0;
      ofail    <= 1'b0;
    end
    else if (start) begin
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

  always @(posedge iclk or posedge irst) begin
    if (irst) begin
      ostart_cmd <= 1'b0;
      ostatus_d  <= 1'b0;
      ostart_d   <= 1'b0;  
      ogen_otp   <= 1'b0;
    end else if (state != next_state) begin
      ostart_cmd <= (next_state != IDLE && next_state != READ && next_state != WRITE && next_state != OTP) ? 1'b1 : 1'b0;
      if (next_state == CMD18 || next_state == WRITE) ostart_d <= 1'b1;
      if (next_state == READ) ogen_otp <= 1'b1;
    end else begin
      ostart_cmd <= icmd_done && (next_state == CMD13 || next_state == CMD6) ? 1'b1 : 1'b0;
      ostatus_d  <= icmd_done && state == CMD6 && next_state == CMD6 ? 1'b1 : 1'b0;
      ostart_d   <= 1'b0;
      ogen_otp   <= 1'b0;
    end
  end
  
  assign onew_otp = state == IDLE; 

endmodule
