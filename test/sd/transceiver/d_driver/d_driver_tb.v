//======================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: d_driver module testbench
//======================================

module d_driver_tb;

  localparam PERIOD = 40;
  localparam HALF_PERIOD = PERIOD / 2;
  
  reg clk, rst, start_read = 1'b0, start_write = 1'b0;
  reg [3:0] idata_sd, rdata;

  wire write_en, crc_fail, done;
  wire [3:0] odata_sd, wdata;
  wire [9:0] addr;

  integer i;

  always begin
    clk = 1'b1;
    #HALF_PERIOD;
    clk = 1'b0;
    #HALF_PERIOD;
  end

  d_driver uut(
    .irst(rst),
    .iclk(clk),

    .idata_sd(idata_sd),
    .odata_sd(odata_sd),
    
    .istart_read(start_read),
    .istart_write(start_write),

    .oaddr(addr),
    .owdata(wdata),
    .owrite_en(write_en),
    .irdata(rdata),

    .ocrc_fail(crc_fail),
    .odone(done)
  );

  initial begin
    $dumpfile("work/wave.ocd");
    $dumpvars(0, d_driver_tb);
  end

  initial begin
    // Reset
    #HALF_PERIOD;    
    rst = 1'b1;
    #PERIOD;    
    rst = 1'b0;

    // Start
    start_read = 1'b1;
  end

  initial begin
    $display("Starting d_driver testbench... (EMPTY TEST)");

    $display("Test passed");
    $finish;
  end

endmodule

