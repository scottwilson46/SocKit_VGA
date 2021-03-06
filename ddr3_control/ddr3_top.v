module ddr3_top #(parameter IMAGE_WIDTH  = 1280,
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

  output                   data_fifo_empty,
  output        [127:0]    data_fifo_rd_data,
  input                    vga_rd_valid,

  output         [31:0]    test_regs,
  input           [3:0]    key_val,
  output                   test_pat

);

parameter READ_DATA_FIFO_DEPTH = 9;
parameter READ_DATA_FIFO_SIZE  = (1<<READ_DATA_FIFO_DEPTH);
parameter READ_DATA_FIFO_SPACE = READ_DATA_FIFO_SIZE-100;

wire tmp1, tmp2;

wire [READ_DATA_FIFO_DEPTH:0] next_fifo_depth_ddr3;
reg  [READ_DATA_FIFO_DEPTH:0] fifo_depth_ddr3;
wire                          almost_full_ddr3;

wire [25:0] ddr3_buffer0_offset;
wire [25:0] ddr3_buffer1_offset;
wire        clear_buffer0, clear_buffer1;
wire        wr_finish;

wire [31:0]  test_addr;
wire [127:0] test_wr_data;
wire         test_wr;
wire [31:0]  test_regs_int;
wire         test_rd_data_valid;

wire [127:0] test_rd_data;
wire         test_rd;
wire         rd_finish;

wire [25:0] ddr3_avl_rd_addr, ddr3_avl_wr_addr;
wire        ddr3_avl_rd_burstbegin, ddr3_avl_wr_burstbegin;
wire  [2:0] ddr3_avl_rd_size, ddr3_avl_wr_size;

wire        ddr3_reset_n;
wire        ddr3_rd_buffer0_empty;
wire        ddr3_rd_buffer1_empty;
wire        ddr3_fifo_almost_full;

wire        in_start_read;

wire  [3:0] debug_out_wr;
reg test;

wire        next_start_write;
reg         start_write;
wire  [7:0] next_write_addr;
reg   [7:0] write_addr;
wire  [7:0] rd_addr_from_regs;
wire [31:0] rd_data_to_regs;

assign test_regs = {28'd0, tmp2, tmp1, data_fifo_empty, debug_out_wr[0]};

always @(posedge ddr3_clk or negedge ddr3_reset_n)
  if (!ddr3_reset_n)
     test <= 1'b0;
  else 
     test <= 1'b1;

reset_sync i_reset_sync_ddr3 (
  .clk                    (ddr3_clk),
  .reset_n                (reset_n),
  .reset_n_sync           (ddr3_reset_n));

read_from_ddr3 #(.IMAGE_WIDTH (IMAGE_WIDTH),
                 .IMAGE_HEIGHT(IMAGE_HEIGHT)) i_read_from_ddr3 (
  .ddr3_clk               (ddr3_clk),
  .ddr3_reset_n           (ddr3_reset_n),
  .clk                    (clk),
  .reset_n                (reset_n),

  .ddr3_rd_buffer0_empty  (ddr3_rd_buffer0_empty),
  .ddr3_rd_buffer1_empty  (ddr3_rd_buffer1_empty),
  .clear_buffer0_clk      (clear_buffer0),
  .clear_buffer1_clk      (clear_buffer1),
  .ddr3_buffer0_offset    (ddr3_buffer0_offset),
  .ddr3_buffer1_offset    (ddr3_buffer1_offset),

  .test_addr              (test_addr),
  .test_rd                (test_rd),
  .test_rd_data           (test_rd_data),
  .rd_finish_clk          (rd_finish),
  .test_rd_data_valid     (test_rd_data_valid),

  .data_fifo_almost_full  (data_fifo_almost_full),

  .ddr3_avl_ready         (ddr3_avl_ready),
  .ddr3_avl_burstbegin    (ddr3_avl_rd_burstbegin),
  .ddr3_avl_size          (ddr3_avl_rd_size),
  .ddr3_avl_read_req      (ddr3_avl_read_req),
  .ddr3_avl_addr          (ddr3_avl_rd_addr),

  .ddr3_avl_read_data_valid (ddr3_avl_read_data_valid),
  .ddr3_avl_read_data     (ddr3_avl_read_data),
  
  .in_start_read          (in_start_read)

);

write_to_ddr3 i_write_to_ddr3 (
  .ddr3_clk               (ddr3_clk),
  .ddr3_reset_n           (ddr3_reset_n),
  .clk                    (clk),
  .reset_n                (reset_n),

  .test_addr              (test_addr),
  .test_wr_data           (test_wr_data),
  .test_wr                (test_wr),
  .wr_finish_clk          (wr_finish),

  .ddr3_avl_ready         (ddr3_avl_ready),
  .ddr3_avl_burstbegin    (ddr3_avl_wr_burstbegin),
  .ddr3_avl_size          (ddr3_avl_wr_size),
  .ddr3_avl_write_req     (ddr3_avl_write_req),
  .ddr3_avl_wr_data       (ddr3_avl_wr_data),
  .ddr3_avl_addr          (ddr3_avl_wr_addr),

  .debug_out              (debug_out_wr));

assign ddr3_avl_burstbegin = ddr3_avl_read_req ? ddr3_avl_rd_burstbegin : ddr3_avl_wr_burstbegin;
assign ddr3_avl_size       = ddr3_avl_read_req ? ddr3_avl_rd_size       : ddr3_avl_wr_size;
assign ddr3_avl_addr       = ddr3_avl_read_req ? ddr3_avl_rd_addr       : ddr3_avl_wr_addr;

async_fifo #(.fifo_data_size    (128),
	     .fifo_ptr_size     (READ_DATA_FIFO_DEPTH),
             .almost_full_space (300)) i_async_fifo (
  .wr_clk                 (ddr3_clk),
  .rd_clk                 (vga_clk),
  .reset_wr               (~ddr3_reset_n),
  .reset_rd               (~vga_reset_n),

  .wr_valid               (ddr3_avl_read_data_valid && ~test_rd_data_valid),
  .rd_valid               (vga_rd_valid),
  .wr_data                (ddr3_avl_read_data),

  .fifo_full              (),
  .fifo_empty             (data_fifo_empty),
  .fifo_almost_full       (data_fifo_almost_full),
  .rd_data                (data_fifo_rd_data));


assign wr_valid = (ddr3_avl_read_data_valid && ~test_rd_data_valid) && start_write;
assign next_start_write = start_write & ~(write_addr == 'd100);
assign next_write_addr  = wr_valid ? write_addr + 'd1 : 
                          write_addr;

async_fifo_memory #(.fifo_data_size(32), .fifo_ptr_size(8)) i_mem (
  .wr_clk      (ddr3_clk),
  .rd_clk      (clk),
  .wr_din      (data_fifo_rd_data[31:0]),
  .wr_addr     (write_addr),
  .wr_en       (wr_valid),
  .rd_addr     (rd_addr_from_regs),
  .wr_data     (),
  .rd_data     (rd_data_to_regs));

always @(posedge ddr3_clk or negedge reset_n)
  if (!reset_n)
  begin
    start_write     <= 1'b1;
    write_addr      <= 'd0;
  end
  else 
  begin
    start_write     <= next_start_write;
    write_addr      <= next_write_addr;
  end


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

  .test_regs              (test_regs_int),
  .test_addr              (test_addr),
  .test_wr_data           (test_wr_data),
  .test_wr_ddr3           (test_wr),

  .test_rd_data           (test_rd_data),
  .test_rd_ddr3           (test_rd),

  .clear_buffer0          (clear_buffer0),
  .clear_buffer1          (clear_buffer1),
  .wr_finish              (wr_finish),
  .rd_finish              (rd_finish),

  .write_addr_dbg         (write_addr),
  .rd_data_dbg            (rd_data_to_regs),

  .rd_addr_dbg            (rd_addr_from_regs),
  
  .tmp1                   (tmp1),
  .tmp2                   (tmp2),
  .test_pat               (test_pat));

endmodule

