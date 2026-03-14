//==========================================
//company: Tomsk State University
//developer: Simon Razenkov
//e-mail: sirazenkov@mail.tsu.ru
//description: Top module of GhostSD project
//==========================================
`timescale 1ns/100ps

module ghost_sd #(
  parameter RAM_BLOCKS = 8
)(
  input  irst,
  input  iclk_otp,
  input  iclk_sd,
  output osel_clk_sd,

  input istart,

  input [255:0] ikey,
  input  [31:0] iiv,

  // SD lines
  inout       iocmd_sd,  // CMD line
  inout [3:0] iodata_sd, // D[3:0] line

  /*
  output [AXI_ID_WIDTH-1:0]    m_axi_awid,
  output [AXI_ADDR_WIDTH-1:0]  m_axi_awaddr,
  output [7:0]                 m_axi_awlen,
  output [2:0]                 m_axi_awsize,
  output [1:0]                 m_axi_awburst,
  output                       m_axi_awlock,
  output [3:0]                 m_axi_awcache,
  output [2:0]                 m_axi_awprot,
  output                       m_axi_awvalid,
  input                        m_axi_awready,
  output [AXI_DATA_WIDTH-1:0]  m_axi_wdata,
  output [AXI_STRB_WIDTH-1:0]  m_axi_wstrb,
  output                       m_axi_wlast,
  output                       m_axi_wvalid,
  input                        m_axi_wready,
  input  [AXI_ID_WIDTH-1:0]    m_axi_bid,
  input  [1:0]                 m_axi_bresp,
  input                        m_axi_bvalid,
  output                       m_axi_bready,
  output [AXI_ID_WIDTH-1:0]    m_axi_arid,
  output [AXI_ADDR_WIDTH-1:0]  m_axi_araddr,
  output [7:0]                 m_axi_arlen,
  output [2:0]                 m_axi_arsize,
  output [1:0]                 m_axi_arburst,
  output                       m_axi_arlock,
  output [3:0]                 m_axi_arcache,
  output [2:0]                 m_axi_arprot,
  output                       m_axi_arvalid,
  input                        m_axi_arready,
  input  [AXI_ID_WIDTH-1:0]    m_axi_rid,
  input  [AXI_DATA_WIDTH-1:0]  m_axi_rdata,
  input  [1:0]                 m_axi_rresp,
  input                        m_axi_rlast,
  input                        m_axi_rvalid,
  output                       m_axi_rready,
  */

  output osuccess,
  output ofail
);

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, ghost_sd);
  end

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

  assign icmd_sd  = iocmd_sd;
  assign idata_sd = iodata_sd;

  sd #(
    .RAM_BLOCKS(RAM_BLOCKS)
  ) sd_inst (
    .irst(irst),
    .iclk(iclk_sd),

    .icmd_sd    (icmd_sd),
    .ocmd_sd    (ocmd_sd),
    .ocmd_sd_en (cmd_sd_en),

    .idata_sd   (idata_sd),
    .odata_sd   (odata_sd),
    .odata_sd_en(data_sd_en),

    .istart(istart),

    .osel_clk(osel_clk_sd),

    .ogen_otp(gen_otp),
    .onew_otp(new_otp),

    .iotp_ready(otp_ready),

    .osel_ram (sel_ram),
    .oaddr    (addr),

    .owdata   (wdata_raw),
    .owrite_en(write_en_raw),

    .irdata(res_block),

    .osuccess(osuccess),
    .ofail   (ofail)
  );

  otp_gen #(
    .RAM_BLOCKS(RAM_BLOCKS)
  ) otp_gen_inst (
    .irst(irst),
    .iclk(iclk_otp),

    .istart(gen_otp),
  
    .inew_otp(new_otp),

    .ikey(ikey),
    .iIV (iiv),

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
        .wclk    (iclk_otp),
        .rclk    (iclk_sd),
        .dout    (rdata_otp[i])
      );

      assign write_en_raw_ram[i] = write_en_raw & (sel_ram == i);
      ram_4k_block raw_block (
        .waddr   (addr),
        .raddr   (addr),
        .din     (wdata_raw),
        .write_en(write_en_raw_ram[i]),
        .wclk    (iclk_sd),
        .rclk    (iclk_sd),
        .dout    (rdata_raw[i])
      );
    end
  endgenerate

  assign block_raw = rdata_raw[sel_ram];
  assign block_otp = rdata_otp[sel_ram];

  assign res_block = block_raw ^ block_otp;

  assign iocmd_sd = cmd_sd_en ? ocmd_sd : 1'bz;
  generate
    for(i = 0; i < 4; i = i + 1) begin : d_io
      assign iodata_sd[i] = data_sd_en ? odata_sd[i] : 1'bz;
    end
  endgenerate

endmodule
