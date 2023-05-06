//==========================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@stud.tsu.ru
//description: Top module of GhostSD project
//==========================================

module ghost_sd (
  `ifndef YOSYS
  input irst_n,
  `else
  input irst,
  `endif

  input iclk, // System clock

  `ifndef YOSYS
  input istart_n,  
  `else
  input istart,  
  `endif

  // SD lines
  inout       iocmd_sd,  // CMD line
  inout [3:0] iodata_sd, // D[3:0] line
  output      oclk_sd,   // CLK line

  output osuccess,
  output ofail
);

  parameter KEY = 256'h34d20ac43f554f1d2fd101496787e3954e39d417e33528f13c005501aa1a9e47;
  parameter IV = 32'hb97b7f46;

  `ifdef COCOTB_SIM
    parameter RAM_BLOCKS = 8;
  `elsif YOSYS
    parameter RAM_BLOCKS = 8;
  `else
    parameter RAM_BLOCKS = 16;
  `endif

  `ifdef COCOTB_SIM
    initial begin
      $dumpfile("wave.vcd");
      $dumpvars(0, ghost_sd);
      #1;
    end
  `endif

  wire icmd_sd, ocmd_sd, cmd_sd_en, clk_sd;

  wire [3:0] idata_sd, odata_sd;
  wire       data_sd_en;

  wire gen_otp, otp_ready, new_otp, clk_otp;

  wire [$clog2(RAM_BLOCKS)-1:0] sel_ram, sel_ram_otp;

  wire       write_en_raw, write_en_otp;
  wire [3:0] wdata_raw,    wdata_otp;
  wire [9:0] addr,         addr_otp;
  wire [3:0] block_otp,    block_raw;
  wire [3:0] res_block;

  wire [3:0] rdata_raw [0:RAM_BLOCKS-1], rdata_otp [0:RAM_BLOCKS-1];
  wire [RAM_BLOCKS-1:0] write_en_raw_ram, write_en_otp_ram;

  wire success, fail;

  wire sel_clk;

  `ifndef YOSYS
    reg debounce_rst = 1, rst = 0;
    always @(posedge iclk) begin
      debounce_rst <= irst_n;
      rst <= ~debounce_rst;
    end
  `else
    wire rst;
    assign rst = irst;
  `endif

  clock_divider clock_divider_inst (
    .irst(rst),
    .iclk(iclk),
    .isel_clk(sel_clk),
    .oclk_otp(clk_otp),
    .oclk_sd(clk_sd)
  );

  `ifndef YOSYS
    reg debounce_start = 1, start = 0;
    always @(posedge clk_sd) begin
      debounce_start <= istart_n;
      start <= ~debounce_start;
    end
  `else
    wire start;
    assign start = istart;
  `endif

  sd #(
    .RAM_BLOCKS(RAM_BLOCKS)
  ) sd_inst (
    .irst(rst),
    .iclk(clk_sd),

    .icmd_sd    (icmd_sd),
    .ocmd_sd    (ocmd_sd),
    .ocmd_sd_en (cmd_sd_en),

    .idata_sd   (idata_sd),
    .odata_sd   (odata_sd),
    .odata_sd_en(data_sd_en),
    
    .istart(start),

    .osel_clk(sel_clk),

    .ogen_otp(gen_otp),
    .onew_otp(new_otp),

    .iotp_ready(otp_ready),

    .osel_ram (sel_ram),
    .oaddr    (addr),

    .owdata   (wdata_raw),
    .owrite_en(write_en_raw),

    .irdata(res_block),

    .osuccess(success),
    .ofail   (fail)
  );

  otp_gen #(
    .RAM_BLOCKS(RAM_BLOCKS)
  ) otp_gen_inst (
    .irst(rst),
    .iclk(clk_otp),

    .istart(gen_otp),
  
    .inew_otp(new_otp),

    .ikey(KEY),
    .iIV (IV),

    .osel_ram (sel_ram_otp),
    .oaddr    (addr_otp),
    .owdata   (wdata_otp),
    .owrite_en(write_en_otp),

    .odone(otp_ready)
  );

  genvar i;
  generate
    for(i = 0; i < RAM_BLOCKS; i = i + 1) begin : ram
      assign write_en_otp_ram[i] = write_en_otp & (sel_ram_otp == i);
      ram_4k_block otp_block (
        .waddr   (addr_otp),
        .raddr   (addr),
        .din     (wdata_otp),
        .write_en(write_en_otp_ram[i]),
        .wclk    (clk_otp),
        .rclk    (clk_sd),
        .dout    (rdata_otp[i])
      );

      assign write_en_raw_ram[i] = write_en_raw & (sel_ram == i);
      ram_4k_block raw_block (
        .waddr   (addr),
        .raddr   (addr),
        .din     (wdata_raw),
        .write_en(write_en_raw_ram[i]),
        .wclk    (clk_sd),
        .rclk    (clk_sd),
        .dout    (rdata_raw[i])
      );
    end
  endgenerate

  assign block_raw = rdata_raw[sel_ram];
  assign block_otp = rdata_otp[sel_ram];

  assign res_block = block_raw ^ block_otp;

  assign oclk_sd  = clk_sd;

  `ifdef YOSYS
    SB_IO #(
      .PIN_TYPE(6'b101001),
      .PULLUP(1'b0),
      .IO_STANDARD("SB_LVCMOS")
    ) cmd_io (
      .CLOCK_ENABLE(1'b0),
      .PACKAGE_PIN(iocmd_sd),
      .OUTPUT_ENABLE(cmd_sd_en),
      .D_OUT_0(ocmd_sd),
      .D_IN_0(icmd_sd)
    );
    SB_IO #(
      .PIN_TYPE(6'b101001),
      .PULLUP(1'b0),
      .IO_STANDARD("SB_LVCMOS")
    ) data_io [3:0] (
      .CLOCK_ENABLE(1'b0),
      .PACKAGE_PIN(iodata_sd),
      .OUTPUT_ENABLE(data_sd_en),
      .D_OUT_0(odata_sd),
      .D_IN_0(idata_sd)
    );
  `else
    assign icmd_sd  = iocmd_sd;
    assign idata_sd = iodata_sd;

    assign iocmd_sd = cmd_sd_en ? ocmd_sd : 1'bz;
    generate
      for(i = 0; i < 4; i = i + 1) begin : d_io
        assign iodata_sd[i] = data_sd_en ? odata_sd[i] : 1'bz;
      end
    endgenerate
  `endif

  `ifdef COCOTB_SIM
    assign osuccess  = success;
    assign ofail     = fail;
    assign odata0_sd = iodata_sd[0];
  `elsif YOSYS
    assign osuccess = success;
    assign ofail    = fail;
  `else
    assign osuccess = success ? 1'b0 : 1'bz;
    assign ofail    = fail ? 1'b0 : 1'bz;
  `endif

endmodule
