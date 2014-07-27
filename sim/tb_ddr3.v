`timescale 1ns/1ps

module tb_ddr3 ();

reg clk, reset;
wire csr_read;
wire csr_write;
wire [31:0] csr_wr_data;
wire [31:0] csr_rd_data;
wire  [7:0] csr_address;
wire data_fifo_empty;

initial
begin 
  clk = 1'b0;
  reset = 1'b0;

  #10 reset = 1'b1;
  #10 reset = 1'b0;

  while(1)
    #10 clk = ~clk;
end


csr_access i_csr_access (
  .clk          (clk),
  .reset_n      (~reset),

  .csr_wr_data  (csr_wr_data),
  .csr_address  (csr_address),
  .csr_write    (csr_write),
  .csr_read     (csr_read),
  .csr_rd_data  (csr_rd_data));

ddr3_top #(.IMAGE_WIDTH  (10),
           .IMAGE_HEIGHT (10)) i_ddr3_top (
  .ddr3_clk         (clk),
  .clk              (clk),
  .vga_clk          (clk),
  .reset_n          (~reset),
  
  .csr_read         (csr_read),
  .csr_write        (csr_write),
  .csr_addr         (csr_address),
  .csr_wr_data      (csr_wr_data),
  .csr_rd_data      (csr_rd_data),

  .ddr3_avl_ready           (1'b1),
  .ddr3_avl_burstbegin      (),
  .ddr3_avl_size            (),
  .ddr3_avl_read_req        (),
  .ddr3_avl_write_req       (),
  .ddr3_avl_wr_data         (),
  .ddr3_avl_addr            (),
  .ddr3_avl_read_data_valid (1'b0),
  .ddr3_avl_read_data       (128'd0),

  .data_fifo_empty      (data_fifo_empty),
  .data_fifo_rd_data    (),
  .vga_rd_valid         (~data_fifo_empty));

initial
begin 
  $dumpfile("new.vcd");
  $dumpvars();
  #10000 $finish;
end

endmodule
