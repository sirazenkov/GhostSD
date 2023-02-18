//===================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: S-box module testbench
//===================================

`timescale 1ns / 1ns

module s_box_tb;

  task automatic check_value (
    input [31:0] arg_val,
    input [31:0] input_port,
    input [31:0] output_port
  ); 
  begin
    input_port = arg_val;

  end
  endtask

  localparam PERIOD = 40;

  reg  [31:0] iword;
  wire [31:0] oword;

  integer i = 1;

  s_box uut(
    .iword(iword),
    .oword(oword)
  );

  initial begin
    $dumpfile("work/wave.ocd");
    $dumpvars(0, s_box_tb);
  end

  initial begin
    $display("Starting S-box testbench...");

    iword = 32'hFDB97531;
    #PERIOD;
    if (oword != 32'h2A196F34) begin
      $display("Error: Test %d failed!", i);
      $finish;
    end
    i = i + 1;

    iword = 32'h2A196F34;
    #PERIOD;
    if (oword != 32'hEBD9F03A) begin
      $display("Error: Test %d failed!", i);
      $finish;
    end
    i = i + 1;

    iword = 32'hEBD9F03A;
    #PERIOD;
    if (oword != 32'hB039BB3D) begin
      $display("Error: Test %d failed!", i);
      $finish;
    end
    i = i + 1;

    iword = 32'hB039BB3D;
    #PERIOD;
    if (oword != 32'h68695433) begin
      $display("Error: Test %d failed!", i);
      $finish;
    end

    $display("Test passed");
    $finish;
  end
endmodule

