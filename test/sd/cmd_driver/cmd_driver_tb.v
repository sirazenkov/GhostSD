//========================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: cmd_driver module testbench
//========================================

module cmd_driver_tb;

  localparam PERIOD = 40;
  localparam HALF_PERIOD = PERIOD / 2;
  
  reg clk, rst = 1'b0, start = 1'b0;
  reg [5:0] cmd_index;
  reg [31:0] cmd_arg;

  reg [46:0] correct_cmd;
  reg [47:0] correct_resp;

  wire [31:0] resp;
  wire cmd_sd, done;
  reg resp_sd = 1'b1;

  integer i;

  always begin
    clk = 1'b1;
    #HALF_PERIOD;
    clk = 1'b0;
    #HALF_PERIOD;
  end

  cmd_driver uut(
    .irst(rst),
    .iclk(clk),

    .icmd_sd(resp_sd),
    .ocmd_sd(cmd_sd),
    
    .istart(start),

    .icmd_index(cmd_index),
    .icmd_arg(cmd_arg),

    .oresp(resp),
    .odone(done)
  );

  initial begin
    $dumpfile("work/wave.ocd");
    $dumpvars(0, cmd_driver_tb);
  end

  initial begin
    // Reset
    #HALF_PERIOD;    
    rst = 1'b1;
    #PERIOD;    
    rst = 1'b0;

    // Start
    start = 1'b1;
  end

  initial begin
    $display("Starting cmd_driver testbench...");

    cmd_index = 6'b010001;
    cmd_arg = {32{1'b0}};
    correct_cmd = {1'b1, 6'b010001, {32{1'b0}}, 7'b0101010, 1'b1};

    @(negedge cmd_sd);
    #HALF_PERIOD;
    for(i = 46; i >= 0; i = i - 1) begin
      #PERIOD;
      if (cmd_sd != correct_cmd[i]) begin
        $display("Error: Command check failed on bit %d", i);
        $finish;
      end
    end

    correct_resp = {1'b0, 1'b0, 6'b010001, 32'h00000900, 7'b0110011, 1'b1};
    for(i = 47; i >= 0; i = i - 1) begin
      #PERIOD;
      resp_sd = correct_resp[i];
    end

    if (!done) begin
      $display("Error: CMD driver didn't finish processing");
      $finish;
    end

    if (resp != correct_resp[39:8]) begin
      $display("Error: Wrong response from CMD driver!");
      $finish;
    end

    $display("Test passed");
    $finish;
  end

endmodule

