module top_no_ddr3 (

  input                    clk_50,
  input                    clk,
  input                    ddr3_clk,
  input                    reset_n,

  output          [7:0]    vga_r,
  output          [7:0]    vga_g,
  output          [7:0]    vga_b,

  input           [3:0]    key_val,

  input                    csr_read,
  input                    csr_write,
  input   [7:0]            csr_addr,
  input  [31:0]            csr_wr_data,
  output [31:0]            csr_rd_data,  

  input                    ddr3_avl_ready,
  output                   ddr3_avl_burstbegin,
  output          [2:0]    ddr3_avl_size,
  output                   ddr3_avl_read_req,
  output                   ddr3_avl_write_req,
  output        [127:0]    ddr3_avl_wr_data,
  output         [25:0]    ddr3_avl_addr,
  
  input                    ddr3_avl_read_data_valid,
  input         [127:0]    ddr3_avl_read_data,
 
  output         [31:0]    test_regs,

  output                   vga_clk,
  output                   vga_hs,
  output                   vga_vs,
  output                   vga_blank_n,
  output                   vga_sync_n);

reg reset_n_sync0;
reg reset_n_sync1;
reg reset_n_sync2;

reg reset_50_n_sync0;
reg reset_50_n_sync1;
reg reset_50_n_sync2;

reg test;
wire [31:0] test_regs_int;

wire [127:0] ddr_fifo_rd_data;
wire         vga_rd_valid;
wire         data_fifo_empty;
wire         vga_test_out;

assign test_regs = {test_regs_int[31:1], vga_test_out};

always @(posedge clk or negedge reset_n)
  if (!reset_n)
  begin
    reset_n_sync0    <= 1'b0;
    reset_n_sync1    <= 1'b0;
    reset_n_sync2    <= 1'b0;
  end
  else
  begin 
    reset_n_sync0    <= reset_n;
    reset_n_sync1    <= reset_n_sync0;
    reset_n_sync2    <= reset_n_sync1;
  end

always @(posedge clk_50 or negedge reset_n)
  if (!reset_n)
  begin
    reset_50_n_sync0    <= 1'b0;
    reset_50_n_sync1    <= 1'b0;
    reset_50_n_sync2    <= 1'b0;
  end
  else
  begin 
    reset_50_n_sync0    <= reset_n;
    reset_50_n_sync1    <= reset_50_n_sync0;
    reset_50_n_sync2    <= reset_50_n_sync1;
  end


// Instantiate PLL for VGA clk:
altera_pll_vga i_pll (
  .refclk                   (clk_50),
  .rst                      (~reset_50_n_sync2),

  .outclk_0                 (vga_clk_int),
  .locked                   (pll_locked));

always @(posedge vga_clk_int or negedge pll_locked)
  if (!pll_locked)
    test <= 1'b0;
  else 
    test <= 1'b1;

assign vga_clk = vga_clk_int;

ddr3_top i_ddr3_top (
  .ddr3_clk                 (ddr3_clk),
  .clk                      (clk),
  .vga_clk                  (vga_clk_int),
  .reset_n                  (reset_n_sync2),
  .vga_reset_n              (pll_locked),
  .csr_read                 (csr_read),
  .csr_write                (csr_write),
  .csr_addr                 (csr_addr),
  .csr_wr_data              (csr_wr_data),
  .csr_rd_data              (csr_rd_data),

  .ddr3_avl_ready           (ddr3_avl_ready),
  .ddr3_avl_burstbegin      (ddr3_avl_burstbegin),
  .ddr3_avl_size            (ddr3_avl_size),
  .ddr3_avl_read_req        (ddr3_avl_read_req),
  .ddr3_avl_write_req       (ddr3_avl_write_req),
  .ddr3_avl_wr_data         (ddr3_avl_wr_data),
  .ddr3_avl_addr            (ddr3_avl_addr),
  .ddr3_avl_read_data_valid (ddr3_avl_read_data_valid),
  .ddr3_avl_read_data       (ddr3_avl_read_data),

  .data_fifo_empty          (data_fifo_empty),
  .data_fifo_rd_data        (ddr_fifo_rd_data),
  .vga_rd_valid             (vga_rd_valid),
  .test_regs                (test_regs_int),
  .test_pat                 (test_pat),
  .key_val                  (key_val));


vga_control i_vga_control (
  .vga_clk                  (vga_clk_int),
  .vga_reset_n              (pll_locked),

  .vga_r                    (vga_r),
  .vga_g                    (vga_g),
  .vga_b                    (vga_b),

  .test_pat                 (test_pat),

  .vga_hs                   (vga_hs),
  .vga_vs                   (vga_vs),
  .vga_blank_n              (vga_blank_n),
  .vga_sync_n               (vga_sync_n),

  .data_fifo_empty          (data_fifo_empty),
  .ddr_fifo_rd_data         (ddr_fifo_rd_data),
  .vga_rd_valid             (vga_rd_valid),
  .test_out                 (vga_test_out));

endmodule
