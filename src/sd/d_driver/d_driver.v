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

  input istart,

  output [9:0] oaddr, // Data address in RAM

  // RAM for received data
  output [3:0] owdata,
  output       owrite_en,

  // RAM with processed data (for sending)
  input [3:0] irdata,

  output reg ocrc_fail,
  output odone
);

  `ifdef COCOTB_SIM
     initial begin
       $dumpfile("wave.vcd");
       $dumpvars(0, d_driver);
       #1;
     end
  `endif

  localparam [2:0]
    IDLE      = 3'b000,
    WAIT_RCV  = 3'b001,
    RCV_DATA  = 3'b011,
    CHECK_CRC = 3'b010,
    WAIT_SEND = 3'b110,
    SEND_DATA = 3'b100,
    SEND_CRC  = 3'b101,
    BUSY      = 3'b111;
  reg [2:0] state = IDLE, next_state;

  reg [3:0]  data;
  reg [10:0] counter  = 11'd0;

  wire unload = state == CHECK_CRC || state == SEND_CRC;

  wire rst_crc;
  assign rst_crc = irst || state == IDLE || state == WAIT_SEND || state == WAIT_RCV;

  wire [3:0] data_crc;
  wire [3:0] crc;
  assign data_crc = state == SEND_DATA ? irdata : data;

  genvar i;
  generate
    for(i = 0; i < 4; i = i + 1) begin
      crc16 crc16_inst (
        .irst(rst_crc),
        .iclk(iclk),

        .idata(data_crc[i]),

        .iunload(unload),
        .ocrc(crc[i])
      );
    end
  endgenerate

  assign odata_sd = state == SEND_DATA || state == SEND_CRC ? data : 4'hF;

  assign owdata    = data;
  assign oaddr     = counter;
  assign owrite_en = state == RCV_DATA;

  assign odone = state == IDLE || state == WAIT_SEND;

  always @(posedge iclk)
    state <= irst ? IDLE : next_state;

  always @(*) begin
    next_state = state;
    case(state)
      IDLE:      if (istart)            next_state = WAIT_RCV;
      WAIT_RCV:  if (~|data)            next_state = RCV_DATA;
      RCV_DATA:  if (&counter[9:0])     next_state = CHECK_CRC;
      CHECK_CRC:
                 if (counter == 10'd15) next_state = WAIT_SEND;
		 else if (crc != data)  next_state = IDLE;
      WAIT_SEND: if (istart)            next_state = SEND_DATA; // Wait until data is processed
      SEND_DATA: if (counter[10])       next_state = SEND_CRC;
      SEND_CRC:  if (counter == 11'd16) next_state = BUSY;
      BUSY:      if (data[0])           next_state = IDLE;      // SD card finished writing 
      default: next_state = IDLE;
    endcase
  end

  always @(posedge iclk) begin
    if (irst)
      data <= 4'h0;
    else if (state == WAIT_SEND && next_state == SEND_DATA)
      data <= 4'h0;
    else if (state == SEND_DATA)
      data <= irdata;
    else if (state == SEND_CRC)
      data <= crc;
    else
      data <= idata_sd;
  end

  always @(posedge iclk) begin
   if (irst)
     ocrc_fail <= 1'b0;
   else if (state == IDLE      && next_state == WAIT_RCV) ocrc_fail <= 1'b0;
   else if (state == CHECK_CRC && next_state == IDLE)     ocrc_fail <= 1'b1;
  end

  always @(posedge iclk) begin
    if (irst)
      counter <= 11'd0;
    else
      counter <= next_state == SEND_DATA ? counter + 1'b1 :
	         state == WAIT_SEND || state != next_state  ? 11'd0 : counter + 1'b1;
  end

endmodule

