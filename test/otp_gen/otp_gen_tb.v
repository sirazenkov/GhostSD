//====================================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: One-time pad generator module testbench
//====================================================

`timescale 1ns / 1ns

module otp_gen_tb;

  localparam PERIOD = 40;
  localparam HALF_PERIOD = PERIOD / 2;

  reg clk, rst = 1'b0, start = 1'b0, new_otp = 1'b0;
  wire done;
  
  reg  [255:0] key = 256'hFFEEDDCCBBAA99887766554433221100F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF; 
  reg  [31:0] IV = 32'd0;

  wire [2:0] sel_ram;
  wire [9:0] addr;
  wire [3:0] wdata;
  wire       write_en;

  integer i;

  otp_gen uut(
    .irst(rst),
    .iclk(clk),

    .istart(start),
    
    .inew_otp(new_otp),

    .ikey(key),
    .iIV(IV),

    .osel_ram(sel_ram),

    .oaddr(addr),
    .owdata(wdata),
    .owrite_en(write_en),

    .odone(done)
  );

  initial begin
    $dumpfile("work/wave.ocd");
    $dumpvars(0, otp_gen_tb);
  end

  always begin
    clk = 1'b1;
    #HALF_PERIOD;
    clk = 1'b0;
    #HALF_PERIOD;
  end

  initial begin
    $display("Starting OTP generator testbench... (EMPTY TEST)");

    // Reset
    rst = 1'b1;
    #PERIOD;
    rst = 1'b0;
    #PERIOD;
    
    start = 1'b1;
    #PERIOD;

    @(done == 1'b1);
    start = 1'b0;
    #PERIOD;

    $display("Test passed");
    $finish;
  end

endmodule

