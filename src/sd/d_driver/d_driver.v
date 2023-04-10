//===============================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: D lines driver
//===============================

module d_driver (
  input irst, // Global reset
  input iclk, // SD clock

  // D line
  input  [3:0] idata_sd,
  output [3:0] odata_sd,
  output       odata_sd_en,

  input istart,

  output [9:0] oaddr, // Data address in RAM

  // RAM for received data
  output [3:0] owdata,
  output       owrite_en,

  // RAM with processed data (for sending)
  input [3:0] irdata,

  output reg ocrc_fail = 1'b0,
  output odone
);

  `ifdef COCOTB_SIM
     initial begin
       $dumpfile("wave.vcd");
       $dumpvars(0, d_driver);
       #1;
     end
  `endif

  localparam [3:0]
    IDLE      = 4'b0000,
    WAIT_RCV  = 4'b0001,
    RCV_DATA  = 4'b0011,
    CHECK_CRC = 4'b0010,
    DONE_RCV  = 4'b0110,
    WAIT_SEND = 4'b0111,
    SEND_DATA = 4'b0101,
    SEND_CRC  = 4'b0100,
    SEND_END  = 4'b1100,
    BUSY      = 4'b1101,
    DONE_SEND = 4'b1111;
  reg [3:0] state = IDLE, next_state;

  reg [3:0]  data    = 4'd0;
  reg [10:0] counter = 11'd0;

  wire unload = state == CHECK_CRC || state == SEND_CRC;

  wire rst_crc;
  assign rst_crc = irst || state == WAIT_RCV || state == WAIT_SEND;

  wire [3:0] data_crc;
  wire [3:0] crc;
  assign data_crc = state == SEND_DATA ? irdata : data;

  genvar i;
  generate
    for(i = 0; i < 4; i = i + 1) begin : d_crc16
      crc16 crc16_inst (
        .irst(rst_crc),
        .iclk(iclk),

        .idata(data_crc[i]),

        .iunload(unload),
        .ocrc(crc[i])
      );
    end
  endgenerate

  assign odata_sd_en = state == SEND_DATA || state == SEND_CRC || state == SEND_END;
  assign odata_sd    = data;

  assign owdata    = data;
  assign oaddr     = counter[9:0];
  assign owrite_en = state == RCV_DATA;

  assign odone = state == DONE_RCV || state == DONE_SEND;

  always @(posedge iclk or posedge irst) begin
    if (irst) state <= IDLE;
    else      state <= next_state;
  end

  always @(*) begin
    next_state = state;
    case(state)
      IDLE:      if (istart)            next_state = WAIT_RCV;
      WAIT_RCV:  if (~|data)            next_state = RCV_DATA;
      RCV_DATA:  if (&counter[9:0])     next_state = CHECK_CRC;
      CHECK_CRC:
                 if (counter == 11'd16) next_state = DONE_RCV;
		 else if (crc != data)  next_state = IDLE;
      DONE_RCV:                         next_state = WAIT_SEND;
      WAIT_SEND: if (istart)            next_state = SEND_DATA; // Wait until data is processed
      SEND_DATA: if (counter[10])       next_state = SEND_CRC;
      SEND_CRC:  if (counter == 11'd16) next_state = SEND_END;
      SEND_END:                         next_state = BUSY;
      BUSY:      if (data[0])           next_state = DONE_SEND;
      default: next_state = IDLE;
    endcase
  end

  always @(posedge iclk or posedge irst) begin
    if (irst)
      data <= 4'h0;
    else if (state == WAIT_SEND && next_state == SEND_DATA)
      data <= 4'h0;
    else if (state == SEND_DATA)
      data <= irdata;
    else if (state == SEND_CRC)
      data <= next_state == SEND_END ? 4'hF : crc;
    else
      data <= idata_sd;
  end

  always @(posedge iclk or posedge irst) begin
   if (irst)
     ocrc_fail <= 1'b0;
   else if (state == IDLE      && next_state == WAIT_RCV) ocrc_fail <= 1'b0;
   else if (state == CHECK_CRC && next_state == IDLE)     ocrc_fail <= 1'b1;
  end

  always @(posedge iclk or posedge irst) begin
    if (irst)
      counter <= 11'd0;
    else
      counter <= next_state == SEND_DATA ? counter + 1'b1 :
	         state == WAIT_SEND || state != next_state  ? 11'd0 : counter + 1'b1;
  end

endmodule

