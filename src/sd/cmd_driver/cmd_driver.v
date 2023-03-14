//===============================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: CMD line driver
//===============================

module cmd_driver (
  input irst, // Global reset
  input iclk, // SD clock

  // CMD line
  input  icmd_sd,
  output ocmd_sd,

  input istart, // Start transaction (command-response)

  input [5:0]  icmd_index, // Command index
  input [31:0] icmd_arg,   // Command argument  

  output [31:0] oresp, // Received response
  output        odone  // Operation done
);

  localparam [2:0]
    IDLE      = 3'b000,
    SEND_CMD  = 3'b001,
    SEND_CRC  = 3'b011,
    WAIT_RESP = 3'b010,
    RCV_RESP  = 3'b110,
    RCV_CRC   = 3'b111;
  reg [2:0] state = IDLE, next_state;

  reg [7:0]  counter     =  8'd0;
  reg        crc_failed  =  1'b0;
  reg [39:0] cmd_content = 40'd0;

  wire change_state;
  assign change_state = ~|counter;

  wire rst_crc;
  wire  unload;
  wire crc_data, crc;
 
  assign rst_crc = irst || state == IDLE || state == WAIT_RESP;
  assign crc_data = state == RCV_RESP ? icmd_sd : cmd_content[39];
  assign unload = state == SEND_CRC || state == RCV_CRC;

  crc7 crc7_inst (
    .irst(rst_crc),
    .iclk(iclk),
    
    .idata  (crc_data),
    .iunload(unload),
    .ocrc   (crc)
  );

  always @(posedge iclk)
    state <= irst ? IDLE : next_state;

  always @(*) begin
    next_state = state;
    case(state)
      IDLE:      if (istart || crc_failed) next_state = SEND_CMD; 
      SEND_CMD:  if (change_state)         next_state = SEND_CRC;
      SEND_CRC:  if (change_state)         next_state = icmd_index == 6'd15 ? IDLE : WAIT_RESP;
      WAIT_RESP: if (!icmd_sd)             next_state = RCV_RESP;
      RCV_RESP:  if (change_state)         next_state = RCV_CRC;
      RCV_CRC:   if (change_state)         next_state = IDLE;
      default: next_state = IDLE;
    endcase
  end

  always @(posedge iclk) begin
    if (irst) counter <= 8'd0;
    else if (state != next_state) begin
      case(next_state)
        SEND_CMD: counter <= 8'd39;
        SEND_CRC: counter <= 8'd6;
	RCV_RESP: counter <= icmd_index == 6'd2 ? 8'd127 : 8'd38;
	RCV_CRC:  counter <= 8'd6;
      endcase
    end else counter <= counter - 1'b1;
  end

  always @(posedge iclk) begin
    if (irst) crc_failed <= 1'b0;
    else if (next_state == SEND_CMD)
      crc_failed <= 1'b0;
    else if (state == RCV_CRC && icmd_sd != crc
	    && icmd_index != 6'd41 && icmd_index != 6'd2) // Ignore R2 and R3 responses for now
      crc_failed <= 1'b1;
  end

  always @(posedge iclk) begin
    if (irst) 
      cmd_content <= 40'd0;
    else if (state == IDLE && next_state == SEND_CMD)
      cmd_content <= {1'b0, 1'b1, icmd_index, icmd_arg};
    else if (state == SEND_CMD)  
      cmd_content <= {cmd_content[38:0], 1'b0};
    else if (state == RCV_RESP)
      cmd_content <= {cmd_content[38:0], icmd_sd};
  end

  assign ocmd_sd = (state == SEND_CMD) ? cmd_content[39] :
                   (state == SEND_CRC) ? crc : 1'b1;
  assign oresp = cmd_content[31:0];
  assign odone = (state == IDLE) && !(crc_failed);

endmodule

