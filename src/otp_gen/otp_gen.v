//==================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: OTP generator (based on GOST "Magma")
//==================================================
`timescale 1ns/100ps

module otp_gen
#(
  parameter RAM_BLOCKS = 8
)(
  input iclk, // System clock
  input irst, // Global reset

  input istart, // Generate new block of the pad

  input inew_otp, // Start new OTP from IV

  input [255:0] ikey,
  input [31:0]  iIV, // Initialization vector

  // RAM for OTP
  output reg [$clog2(RAM_BLOCKS)-1:0] osel_ram,

  output reg [9:0] oaddr,
  output reg [3:0] owdata,
  output reg       owrite_en,

  output odone
);

  `ifdef COCOTB_SIM
     initial begin
       $dumpfile("wave.vcd");
       $dumpvars(0, otp_gen);
       #1;
     end
  `endif

  localparam [1:0]
    IDLE        = 2'b00,
    GEN_BLOCK   = 2'b01,
    WRITE_BLOCK = 2'b11;
  reg [1:0] state = IDLE, next_state;

  reg [9+$clog2(RAM_BLOCKS):0] counter = {(10+$clog2(RAM_BLOCKS)){1'b0}};
  
  wire done_gost;

  always @(*) begin
    next_state = state;
    case(state)
      IDLE:        if (istart)        next_state = GEN_BLOCK;
      GEN_BLOCK:   if (done_gost)     next_state = WRITE_BLOCK;
      WRITE_BLOCK: if (&counter[3:0]) next_state = &counter[9+$clog2(RAM_BLOCKS):4] ? IDLE :
                                                                                      GEN_BLOCK;
      default:                        next_state = IDLE;
    endcase
  end

  always @(posedge iclk or posedge irst) begin
    if (irst) state <= IDLE;
    else      state <= next_state;
  end

  reg start_gost = 1'b0;

  reg  [63:0] plain_block = 64'd0;
  wire [63:0] enc_block;

  always @(posedge iclk) begin
    start_gost <= state != next_state && next_state == GEN_BLOCK;
  end

  always @(posedge iclk or posedge irst) begin
    if (irst) begin
      counter     <= {(10+$clog2(RAM_BLOCKS)){1'b0}};
      plain_block <= 64'd0;
    end else begin
      case(state)
        IDLE:
          if (inew_otp)
            plain_block <= {iIV, {32{1'b0}}};
        GEN_BLOCK:
          if (done_gost)
            plain_block[22:0] <= plain_block[22:0] + 1'b1;
        WRITE_BLOCK:
          counter <= counter + 1'b1;
      endcase
    end
  end

  gost gost_inst (
    .irst(irst),
    .iclk(iclk),

    .istart(start_gost),

    .ikey  (ikey),
    .iblock(plain_block),

    .oblock(enc_block),
    .odone (done_gost)
  );

  always @(posedge iclk or posedge irst) begin
    if (irst) begin
      osel_ram  <= {$clog2(RAM_BLOCKS){1'b0}};

      oaddr     <= 10'd0;
      owdata    <=  4'd0;
      owrite_en <=  1'b0;
    end else begin
      osel_ram  <= counter[10+$clog2(RAM_BLOCKS)-1:10];

      oaddr     <= counter[9:0];
      owdata    <= enc_block[4*(16-counter[3:0])-1 -: 4];
      owrite_en <= state == WRITE_BLOCK;
    end
  end

  assign odone = state == IDLE;

endmodule
