
module async_fifo_memory #(parameter fifo_data_size = 8, fifo_ptr_size = 8)
          (
  input                           wr_clk,
  input                           rd_clk,
  input      [fifo_data_size-1:0] wr_din, 
  input           [fifo_ptr_size-1:0] wr_addr,
  input                           wr_en,
  input           [fifo_ptr_size-1:0] rd_addr,
  output reg [fifo_data_size-1:0] wr_data,
  output reg [fifo_data_size-1:0] rd_data);


  reg  [fifo_data_size - 1:0] ram [(1<<fifo_ptr_size) - 1:0];
  reg  [fifo_data_size - 1:0] dout_b;
  reg  [fifo_data_size - 1:0] dout_a;

  always @(posedge wr_clk)
    begin 
      if (wr_en == 1'b1) begin
        ram[wr_addr] <= wr_din;
        wr_data <= wr_din;
      end
      else begin
        wr_data <= ram[wr_addr];
      end
    end

  always @(posedge rd_clk)
      rd_data <= ram[rd_addr];


endmodule 
