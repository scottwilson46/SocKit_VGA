`timescale 1ns/1ps

module tb_ddr3 ();

reg clk, reset;
wire csr_read;
wire csr_write;
wire [31:0] csr_wr_data;
wire [31:0] csr_rd_data;
wire  [7:0] csr_address;
wire data_fifo_empty;

wire         ddr3_avl_ready;
wire         ddr3_avl_burstbegin;
wire  [25:0] ddr3_avl_addr;
wire         ddr3_avl_rdata_valid;
wire [127:0] ddr3_avl_rdata;
wire [127:0] ddr3_avl_wdata;
wire         ddr3_avl_read_req;
wire         ddr3_avl_write_req;
wire   [2:0] ddr3_avl_size; 

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

  .ddr3_avl_ready           (ddr3_avl_ready),
  .ddr3_avl_burstbegin      (ddr3_avl_burstbegin),
  .ddr3_avl_addr            (ddr3_avl_addr),
  .ddr3_avl_read_data_valid (ddr3_avl_rdata_valid),
  .ddr3_avl_read_data       (ddr3_avl_rdata),
  .ddr3_avl_wr_data         (ddr3_avl_wdata),
  .ddr3_avl_read_req        (ddr3_avl_read_req),
  .ddr3_avl_write_req       (ddr3_avl_write_req),
  .ddr3_avl_size            (ddr3_avl_size),

  .data_fifo_empty      (data_fifo_empty),
  .data_fifo_rd_data    (),
  .vga_rd_valid         (~data_fifo_empty));

ddr3_controller_sim i_ddr3_sim (
  .sodimm1_ddr3_avl_clk             (clk),
  .sodimm1_ddr3_avl_reset_n         (~reset),
  .sodimm1_ddr3_avl_ready           (ddr3_avl_ready),
  .sodimm1_ddr3_avl_burstbegin      (ddr3_avl_burstbegin),
  .sodimm1_ddr3_avl_addr            (ddr3_avl_addr),
  .sodimm1_ddr3_avl_rdata_valid     (ddr3_avl_rdata_valid),
  .sodimm1_ddr3_avl_rdata           (ddr3_avl_rdata),
  .sodimm1_ddr3_avl_wdata           (ddr3_avl_wdata),
  .sodimm1_ddr3_avl_be              (ddr3_avl_be),
  .sodimm1_ddr3_avl_read_req        (ddr3_avl_read_req),
  .sodimm1_ddr3_avl_write_req       (ddr3_avl_write_req),
  .sodimm1_ddr3_avl_size            (ddr3_avl_size));

initial
begin 
  $dumpfile("new.vcd");
  $dumpvars();
  #10000 $finish;
end

endmodule
