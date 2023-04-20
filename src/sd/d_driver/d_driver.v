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

  output [2:0] osel_ram,
  output [9:0] oaddr, // Data address in RAM

  // RAM for received data
  output [3:0] owdata,
  output       owrite_en,

  // RAM with processed data (for sending)
  input [3:0] irdata,

  output reg ostop_data,
  output     oread_done,
  output     owrite_done
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
    WAIT_SEND = 4'b0110,
    SEND_DATA = 4'b0111,
    SEND_CRC  = 4'b0101,
    SEND_END  = 4'b0100,
    BUSY      = 4'b1100;
  reg [3:0] state = IDLE, next_state;

  reg [3:0]  data        =  4'd0;
  reg [10:0] counter     = 11'd0;
  reg [2:0]  counter_ram =  3'd0;

  wire unload = state == CHECK_CRC || state == SEND_CRC;

  wire rst_crc;
  assign rst_crc = irst || state == WAIT_RCV || state == WAIT_SEND || state == SEND_END;

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
  assign osel_ram  = counter_ram;
  assign oaddr     = counter[9:0];
  assign owrite_en = state == RCV_DATA;

  assign oread_done  = state == WAIT_SEND;
  assign owrite_done = state == IDLE;

  always @(posedge iclk or posedge irst) begin
    if (irst)
      ostop_data <= 1'b0;
    else if ((state == RCV_DATA || state == SEND_DATA) && &counter_ram)
      ostop_data <= 1'b1;
    else
      ostop_data <= 1'b0;
  end

  always @(posedge iclk or posedge irst) begin
    if (irst) state <= IDLE;
    else      state <= next_state;
  end

  always @(*) begin
    next_state = state;
    case(state)
      IDLE:      if (istart)                  next_state = WAIT_RCV;
      WAIT_RCV:  if (~|data)                  next_state = RCV_DATA;
      RCV_DATA:  if (&counter[9:0])           next_state = CHECK_CRC;
      CHECK_CRC: if (counter[4])              next_state = &counter_ram ? WAIT_SEND : WAIT_RCV;
                 else if (crc != data)        next_state = IDLE;
      WAIT_SEND: if (istart)                  next_state = SEND_DATA; // Wait until data is processed
      SEND_DATA: if (counter[10])             next_state = SEND_CRC;
      SEND_CRC:  if (counter[4])              next_state = SEND_END;
      SEND_END:                               next_state = BUSY;
      BUSY:      if (idata_sd[0] && ~data[0]) next_state = &counter_ram ? IDLE : SEND_DATA;
      default:                                next_state = IDLE;
    endcase
  end

  always @(posedge iclk or posedge irst) begin
    if (irst)
      data <= 4'h0;
    else if (state != next_state && next_state == SEND_DATA)
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
      counter_ram <= 3'd0;
    else if (state == IDLE)
      counter_ram <= 3'd0;
    else if (state != next_state && (state == RCV_DATA || state == SEND_DATA))
      counter_ram <= counter_ram + 1'b1;
  end

  always @(posedge iclk or posedge irst) begin
    if (irst)
      counter <= 11'd0;
    else if (next_state == SEND_DATA)
      counter <= counter + 1'b1;
    else if (state != next_state)
      counter <= 11'd0;
    else if (state != WAIT_SEND && state != BUSY)
      counter <= counter + 1'b1;
  end

endmodule

