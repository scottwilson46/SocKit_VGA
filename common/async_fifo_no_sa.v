module async_fifo_no_sa #(parameter fifo_data_size = 8, fifo_ptr_size = 8)
(
  // Clocks and resets:
  input                           wr_clk,
  input                           rd_clk,
  input                           reset_wr,
  input                           reset_rd,

  // FIFO Input Signals:
  input                           wr_valid,
  input                           rd_valid,
  input      [fifo_data_size-1:0] wr_data,

  // FIFO Output Signals:
  output                          fifo_full,
  output                          fifo_empty,
  output                          fifo_almost_full,
  output     [fifo_data_size-1:0] rd_data);

  wire [fifo_ptr_size-1:0] rd_mem_addr;
  wire [fifo_ptr_size-1:0] wr_mem_addr;
  wire [fifo_ptr_size:0]   wr_ptr_gray;
  wire [fifo_ptr_size:0]   rd_ptr_gray;


  async_fifo_memory # (.fifo_data_size(fifo_data_size),
                       .fifo_ptr_size(fifo_ptr_size)) uMem
  (
    .wr_clk         (wr_clk),
    .rd_clk         (rd_clk),
    .wr_din         (wr_data),
    .wr_addr        (wr_mem_addr),
    .wr_en          (wr_valid),
    .rd_addr        (rd_mem_addr),
    .wr_data        (),
    .rd_data        (rd_data));

  async_fifo_calc # (.fifo_data_size(fifo_data_size),
                     .fifo_ptr_size(fifo_ptr_size)) i_fifo_calc_wr
  (
    .clk               (wr_clk),
    .reset             (reset_wr),
    .update_valid      (wr_valid),
    .other_ptr_gray    (rd_ptr_gray),
    .mem_addr          (wr_mem_addr),
    .ptr_gray          (wr_ptr_gray),
    .fifo_full         (fifo_full),
    .fifo_empty        (),
    .fifo_almost_full  (fifo_almost_full));

  async_fifo_calc # (.fifo_data_size(fifo_data_size),
                     .fifo_ptr_size(fifo_ptr_size)) i_fifo_calc_rd
  (
    .clk               (rd_clk),
    .reset             (reset_rd),
    .update_valid      (rd_valid),
    .other_ptr_gray    (wr_ptr_gray),
    .mem_addr          (rd_mem_addr),
    .ptr_gray          (rd_ptr_gray),
    .fifo_full         (),
    .fifo_empty        (fifo_empty),
    .fifo_almost_full  ());

endmodule
