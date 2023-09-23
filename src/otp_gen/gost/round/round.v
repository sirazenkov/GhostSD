//============================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: GOST (Magma) block cipher round
//============================================

module round (
  input irst,
  input iclk,

  input istart,

  input [63:0] iblock,
  input [31:0] ikey,

  output [63:0] oblock,
  output        odone
);

  `ifdef COCOTB_SIM
     initial begin
       $dumpfile("wave.vcd");
       $dumpvars(0, round);
       #1;
     end
  `endif

  localparam [1:0]
    IDLE = 2'b00,
    BUSY = 2'b01,
    DONE = 2'b11;
  reg [1:0] state = IDLE;

  reg [31:0] half_block = {32{1'b0}};

  wire [31:0] s_box_output;
  s_box s_box_inst (
    .iword(half_block),
    .oword(s_box_output)
  );

  always @(posedge iclk or posedge irst) begin
    if (irst) begin
      state <= IDLE;
      half_block <= {32{1'b0}};
    end
    else begin
      case(state)
        IDLE: begin
          if (istart) begin
            half_block <= iblock[31:0] + ikey;
            state      <= BUSY;
          end
        end
        BUSY: begin
          half_block <= ((s_box_output << 11) | (s_box_output >> (32-11))) ^ iblock[63:32];
          state <= DONE;
        end
        DONE:
          state <= IDLE;
      endcase
    end
  end

  assign oblock = (iblock[31:0] << 32) | half_block;
  assign odone  = state == DONE;

endmodule

