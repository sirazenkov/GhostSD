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

  input istart_read,
  input istart_write,

  output [9:0] oaddr, // Data address in RAM

  // RAM for received data
  output [3:0] owdata,
  output       owrite_en,

  // RAM with processed data (for sending)
  input [3:0] irdata,

  output ocrc_fail,
  output odone
);

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

  reg [3:0] data     =  4'h0;
  reg [9:0] counter  = 10'd0;
  reg       crc_fail =  1'b0;

  reg unload = 1'b0;

  wire rst_crc;
  assign rst_crc = irst || state == IDLE || state == WAIT_SEND || state == WAIT_RCV;

  wire [3:0] crc;

  genvar i;
  generate
    for(i = 0; i < 4; i = i + 1) begin
      crc16 crc16_inst (
        .irst(rst_crc),
        .iclk(iclk),

        .idata(data[i]),

        .iunload(unload),
        .ocrc(crc[i])
      );
    end
  endgenerate

  assign odata_sd = state == SEND_DATA || state == SEND_CRC ? data : 4'hF;

  assign owdata    = data;
  assign oaddr     = counter;
  assign owrite_en = state == RCV_DATA;

  assign ocrc_fail = crc_fail;
  assign odone     = state == IDLE || state == WAIT_SEND;

  always @(posedge iclk)
    state <= irst ? IDLE : next_state;

  always @(*) begin
    next_state = state;
    case(state)
      IDLE:      if (istart_read)       next_state = WAIT_RCV;
      WAIT_RCV:  if (data == 4'h0)      next_state = RCV_DATA;
      RCV_DATA:  if (&counter)          next_state = CHECK_CRC;
      CHECK_CRC:
                 if (counter == 10'd15) next_state = WAIT_SEND;
		 else if  (crc != data) next_state = IDLE;
      WAIT_SEND: if (istart_write)      next_state = SEND_DATA; // Wait until data is processed
      SEND_DATA: if (&counter)          next_state = SEND_CRC;
      SEND_CRC:  if (counter == 10'd15) next_state = BUSY;
      BUSY:      if (idata_sd[0])       next_state = IDLE;      // SD card finished writing 
      default: next_state = IDLE;
    endcase
  end

  always @(posedge iclk) begin
    if (irst)  
      data <= 4'h0;
    if (state == IDLE || state == RCV_DATA || state == CHECK_CRC)
      data <= idata_sd;
    else if (istart_write && state == WAIT_SEND)
      data <= 4'h0;  // Send start bit
    else if (state == SEND_DATA && &counter)
      data <= crc;  
    else if (state == SEND_CRC && counter == 10'd15)
      data <= 4'hf;  // Send end bit
    else
      data <= irdata;
  end

  always @(posedge iclk) begin
    if (irst) begin
      counter  <= 10'd0;
      unload   <=  1'b0;
      crc_fail <=  1'b0;
    end
    else begin
      case(state)
        IDLE: begin
          if (istart_read) begin
            counter  <= 10'd0;
            crc_fail <=  1'b0;
          end
        end
        RCV_DATA: begin
          counter <= counter + 1'b1;
          if (&counter) begin
            counter <= 10'd0;
            unload  <=  1'b1;
          end
        end
	CHECK_CRC: begin // Check CRC on the data lines
          counter <= counter + 1'b1;
          if (crc != data)
            crc_fail <= 1'b1;
        end
	WAIT_SEND: begin
          if (istart_write)
            counter <= 10'd0;
        end
        SEND_DATA: begin
          counter <= counter + 1'b1;
          if (&counter) begin
            unload  <=  1'b1;
            counter <= 10'd0;
          end
        end
        SEND_CRC: begin
          counter <= counter + 1'b1;
          if (counter == 10'd15)
            unload <= 1'b0;
        end
      endcase
    end
  end

endmodule

