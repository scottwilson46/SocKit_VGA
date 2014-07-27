module ddr3_top #(parameter IMAGE_WIDTH = 1280,
                  parameter IMAGE_HEIGHT = 1024) (
  input                    ddr3_clk,
  input                    clk,
  input                    vga_clk,
  input                    reset_n,
  input                    vga_reset_n,

  input                    csr_read,
  input                    csr_write,
  input   [7:0]            csr_addr,
  input  [31:0]            csr_wr_data,
  input  [31:0]            csr_rd_data,  

  input                    ddr3_avl_ready,
  output                   ddr3_avl_burstbegin,
  output          [2:0]    ddr3_avl_size,
  output                   ddr3_avl_read_req,
  output         [25:0]    ddr3_avl_addr,
  input                    ddr3_avl_read_data_valid,
  input         [127:0]    ddr3_avl_read_data,

  output                   data_fifo_empty,
  output        [127:0]    data_fifo_rd_data,
  input                    vga_rd_valid,

  output         [31:0]    test_regs

);

wire [25:0] ddr3_buffer0_offset;
wire [25:0] ddr3_buffer1_offset;

reset_sync i_reset_sync_ddr3 (
  .clk                    (ddr3_clk),
  .reset_n                (reset_n),
  .reset_n_sync           (ddr3_reset_n));

read_from_ddr3 #(.IMAGE_WIDTH (IMAGE_WIDTH),
                 .IMAGE_HEIGHT(IMAGE_HEIGHT)) i_read_from_ddr3 (
  .ddr3_clk               (ddr3_clk),
  .reset_n                (ddr3_reset_n),

  .ddr3_rd_buffer0_empty  (ddr3_rd_buffer0_empty),
  .ddr3_rd_buffer1_empty  (ddr3_rd_buffer1_empty),
  .clear_buffer0          (clear_buffer0),
  .clear_buffer1          (clear_buffer1),
  .ddr3_buffer0_offset    (ddr3_buffer0_offset),
  .ddr3_buffer1_offset    (ddr3_buffer1_offset),

  .data_fifo_almost_full  (data_fifo_almost_full),

  .ddr3_avl_ready         (ddr3_avl_ready),
  .ddr3_avl_burstbegin    (ddr3_avl_burstbegin),
  .ddr3_avl_size          (ddr3_avl_size),
  .ddr3_avl_read_req      (ddr3_avl_read_req),
  .ddr3_avl_addr          (ddr3_avl_addr));
 
async_fifo #(.fifo_data_size(128),
	         .fifo_ptr_size (9)) i_async_fifo (
  .wr_clk                 (ddr3_clk),
  .rd_clk                 (vga_clk),
  .reset_wr               (ddr3_reset_n),
  .reset_rd               (vga_reset_n),

  .wr_valid               (ddr3_avl_read_data_valid),
  .rd_valid               (vga_rd_valid),
  .wr_data                (ddr3_avl_read_data),

  .fifo_full              (),
  .fifo_empty             (data_fifo_empty),
  .fifo_almost_full       (data_fifo_almost_full),
  .rd_data                (data_fifo_rd_data));

ddr3_regs i_ddr3_regs (
  .clk                    (clk),
  .ddr3_clk               (ddr3_clk),
  .reset_n                (reset_n),
  .ddr3_reset_n           (ddr3_reset_n),

  .csr_read               (csr_read),
  .csr_write              (csr_write),
  .csr_addr               (csr_addr),
  .csr_wr_data            (csr_wr_data),
  .csr_rd_data            (csr_rd_data),

  .ddr3_rd_buffer0_empty  (ddr3_rd_buffer0_empty),
  .ddr3_rd_buffer1_empty  (ddr3_rd_buffer1_empty),

  .ddr3_buffer0_offset    (ddr3_buffer0_offset),
  .ddr3_buffer1_offset    (ddr3_buffer1_offset),

  .test_regs              (test_regs),

  .clear_buffer0          (clear_buffer0),
  .clear_buffer1          (clear_buffer1));

endmodule

