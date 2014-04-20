module async_fifo #(parameter fifo_data_size = 8, fifo_ptr_size = 8)
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

reg dout_valid;
wire [fifo_data_size-1:0] rd_data_int;
reg  [fifo_data_size-1:0] rd_data_reg;
reg                       rd_valid_reg;

async_fifo_no_sa #(.fifo_data_size (fifo_data_size),
                   .fifo_ptr_size  (fifo_ptr_size)) i_async_fifo_no_sa (
  .wr_clk           (wr_clk),
  .rd_clk           (rd_clk),
  .reset_wr         (reset_wr),
  .reset_rd         (reset_rd),

  .wr_valid         (wr_valid && ~fifo_full),
  .rd_valid         (rd_valid_int),
  .wr_data          (wr_data),

  .fifo_full        (fifo_full),
  .fifo_empty       (fifo_empty_int),
  .fifo_almost_full (fifo_almost_full),
  .rd_data          (rd_data_int));

assign rd_valid_int = ~fifo_empty_int & (~dout_valid | rd_valid);
assign fifo_empty   = ~dout_valid;

assign rd_data = rd_valid_reg ? rd_data_int : rd_data_reg;

always @(posedge rd_clk or posedge reset_rd)
  if (reset_rd)
  begin
    dout_valid   <= 1'b0;
    rd_data_reg  <= 'd0;
    rd_valid_reg <= 1'b0; 
  end
  else 
  begin
    rd_data_reg  <= rd_data;
    rd_valid_reg <= rd_valid_int;
    if (rd_valid_int)
      dout_valid <= 1'b1;
    else if (rd_valid)
      dout_valid <= 1'b0;
  end

endmodule
