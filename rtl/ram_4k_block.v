//==========================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: 4Kb RAM memory block (1024x4)
//==========================================
`timescale 1ns/100ps

module ram_4k_block (din, write_en, waddr, wclk, raddr, rclk, dout);
  parameter addr_width = 10;
  parameter data_width = 4;

  input [addr_width-1:0] waddr, raddr;
  input [data_width-1:0] din;

  input write_en, wclk, rclk;

  output reg [data_width-1:0] dout;
 

  reg [data_width-1:0] mem [(1<<addr_width)-1:0];

  always @(posedge wclk) begin // Write memory
    if (write_en)
      mem[waddr] <= din; // Using write address bus
  end

  always @(posedge rclk) // Read memory
    dout <= mem[raddr];  // using read address bus
endmodule

