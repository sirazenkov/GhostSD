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
       $dumpfile("../../../../test/sd/transceiver/d_driver/wave.vcd");
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

  reg unload = 1'b0;

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

  assign odata_sd = next_state == SEND_DATA || state == SEND_DATA || state == SEND_CRC ? data : 4'hF;

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
    if (irst) begin
      counter   <= 11'd0;
      unload    <=  1'b0;
      ocrc_fail <=  1'b0;
    end
    else begin
      case(state)
        IDLE: begin
          if (next_state == RCV_DATA) begin
            ocrc_fail <=  1'b0;
          end
        end
        RCV_DATA: begin
          counter <= counter + 1'b1;
          if (next_state == CHECK_CRC) begin
            counter <= 11'd0;
            unload  <=  1'b1;
          end
        end
	CHECK_CRC: begin // Check CRC on the data lines
	  if (next_state == WAIT_SEND) begin
	    counter <= 11'd0;
	    unload  <= 1'b0;
	  end else counter <= counter + 1'b1;
	  if (next_state == IDLE) ocrc_fail <= 1'b1;
        end
        WAIT_SEND: begin
	  if (next_state == SEND_DATA) counter <= counter + 1;
        end
	SEND_DATA: begin
          counter <= counter + 1'b1;
          if (next_state == SEND_CRC) begin
            counter <= 11'd0;
            unload  <= 1'b1;
          end
        end
        SEND_CRC: begin
          counter <= counter + 1'b1;
	  if (next_state == BUSY) begin
            counter <= 11'd0;
            unload  <= 1'b0;
	  end
        end
      endcase
    end
  end

endmodule

