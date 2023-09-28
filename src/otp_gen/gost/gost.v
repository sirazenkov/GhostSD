//=============================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: GOST (Magma) block cipher module
//=============================================
`timescale 1ns/100ps

module gost (
  input irst,
  input iclk,
  
  input istart,

  input [255:0] ikey,
  input [63:0]  iblock,
  
  output [63:0] oblock,
  output        odone
);

  `ifdef COCOTB_SIM
     initial begin
       $dumpfile("wave.vcd");
       $dumpvars(0, gost);
       #1;
     end
  `endif

  localparam [1:0]
    IDLE = 2'b00,
    ENC  = 2'b01,
    KEY  = 2'b11,
    DONE = 2'b10;
  reg [1:0] state = IDLE, next_state;

  reg [4:0] counter = 5'd0;

  wire round_start, round_done;
  assign round_start = state == ENC;

  reg  [63:0] block = 64'd0;
  wire [63:0] round_oblock;

  reg [31:0] round_key = 32'd0;

  always @(*) begin
    next_state = state;
    case(state)
      IDLE: if (istart)     next_state = ENC;
      ENC:  if (round_done) next_state = counter == 5'b11111 ? DONE : KEY;
      KEY:                  next_state = ENC;
      default:              next_state = IDLE;
    endcase
  end

  always @(posedge iclk or posedge irst) begin
    if (irst) state <= IDLE;
    else      state <= next_state;
  end

  always @(posedge iclk or posedge irst) begin
    if (irst)
      counter <= 5'b00000;
    else begin
      case(state)
        IDLE: begin
          if (istart) begin
            counter <= 5'b00000;  
            block   <= iblock;
          end
        end
        ENC: begin
          if (round_done) begin
            if (next_state == DONE)
              block <= (round_oblock[31:0] << 32) | round_oblock[63:32];
            else
              block <= round_oblock;
            counter <= counter + 1'b1;
          end
        end
      endcase
    end
  end

  always @(posedge iclk or posedge irst) begin
    if (irst) round_key <= 5'd0;
    else begin
      case(counter)
        5'd0, 5'd8,  5'd16, 5'd31 : round_key <= ikey[255:224];
        5'd1, 5'd9,  5'd17, 5'd30 : round_key <= ikey[223:192];
        5'd2, 5'd10, 5'd18, 5'd29 : round_key <= ikey[191:160];
        5'd3, 5'd11, 5'd19, 5'd28 : round_key <= ikey[159:128];
        5'd4, 5'd12, 5'd20, 5'd27 : round_key <= ikey[127:96];
        5'd5, 5'd13, 5'd21, 5'd26 : round_key <= ikey[95:64];
        5'd6, 5'd14, 5'd22, 5'd25 : round_key <= ikey[63:32];
        5'd7, 5'd15, 5'd23, 5'd24 : round_key <= ikey[31:0];
      endcase
    end
  end

  round round_inst (
    .irst(irst),
    .iclk(iclk),

    .istart(round_start),

    .iblock(block),
    .ikey  (round_key),

    .oblock(round_oblock),
    .odone (round_done)
  );

  assign oblock = block;
  assign odone  = state == DONE;

endmodule

