module top (

  input                    clk,
  input                    reset_n,

  output          [14:0]   DDR3_A,
  output          [2:0]    DDR3_BA,
  output                   DDR3_CAS_n,
  output                   DDR3_CKE,
  output                   DDR3_CK_n,
  output                   DDR3_CK_p,
  output                   DDR3_CS_n,
  output          [3:0]    DDR3_DM,
  inout           [31:0]   DDR3_DQ,
  inout           [3:0]    DDR3_DQS_n,
  inout           [3:0]    DDR3_DQS_p,
  output                   DDR3_ODT,
  output                   DDR3_RAS_n,
  output                   DDR3_RESET_n,
  input                    DDR3_RZQ,
  output                   DDR3_WE_n,

  output          [7:0]    vga_r,
  output          [7:0]    vga_g,
  output          [7:0]    vga_b,

  input                    test_pat,

  input                    csr_read,
  input                    csr_write,
  input   [7:0]            csr_addr,
  input  [31:0]            csr_wr_data,
  input  [31:0]            csr_rd_data,  

  output                   vga_clk,
  output                   vga_hs,
  output                   vga_vs,
  output                   vga_blank_n,
  output                   vga_sync_n);

wire         ddr3_avl_ready;
wire         ddr3_avl_burstbegin;
wire [25:0]  ddr3_avl_addr;
wire         ddr3_avl_rdata_valid;
wire [127:0] ddr3_avl_rdata;
wire         ddr3_avl_read_req;
wire [2:0]   ddr3_avl_size;
wire         ddr3_local_init_done;
wire         ddr3_local_cal_success;
wire         ddr3_local_cal_fail;


top_no_ddr3 i_top_no_ddr3 (
  .clk                      (clk),
  .reset_n                  (reset_n),

  .vga_r                    (vga_r),
  .vga_g                    (vga_g),
  .vga_b                    (vga_b),

  .test_pat                 (1'b0),

  .csr_read                 (csr_read),
  .csr_write                (csr_write),
  .csr_addr                 (csr_addr),
  .csr_wr_data              (csr_wr_data),
  .csr_rd_data              (csr_rd_data),

  .ddr3_avl_ready           (ddr3_avl_ready),
  .ddr3_avl_burstbegin      (ddr3_avl_burstbegin),
  .ddr3_avl_size            (ddr3_avl_size),
  .ddr3_avl_read_req        (ddr3_avl_read_req),
  .ddr3_avl_addr            (ddr3_avl_addr),
  .ddr3_avl_read_data_valid (ddr3_avl_read_data_valid),
  .ddr3_avl_read_data       (ddr3_avl_read_data),

  .vga_clk                  (vga_clk),
  .vga_hs                   (vga_hs),
  .vga_vs                   (vga_vs),
  .vga_blank_n              (vga_blank_n),
  .vga_sync_n               (vga_sync_n));

fpga_ddr3 fpga_ddr3_inst(
  .pll_ref_clk              (clk),
  .global_reset_n           (reset_n),    
  .soft_reset_n             (reset_n),      
  .afi_clk                  (ddr3_clk),          
  .afi_half_clk             (),      
  .afi_reset_n              (),       
  .mem_a                    (DDR3_A),             
  .mem_ba                   (DDR3_BA),            
  .mem_ck                   (DDR3_CK_p),            
  .mem_ck_n                 (DDR3_CK_n),          
  .mem_cke                  (DDR3_CKE),           
  .mem_cs_n                 (DDR3_CS_n),          
  .mem_dm                   (DDR3_DM),            
  .mem_ras_n                (DDR3_RAS_n),         
  .mem_cas_n                (DDR3_CAS_n),         
  .mem_we_n                 (DDR3_WE_n),          
  .mem_reset_n              (DDR3_RESET_n),       
  .mem_dq                   (DDR3_DQ),            
  .mem_dqs                  (DDR3_DQS_p),           
  .mem_dqs_n                (DDR3_DQS_n),         
  .mem_odt                  (DDR3_ODT),    

  .avl_ready                (ddr3_avl_ready),         
  .avl_burstbegin           (ddr3_avl_burstbegin),    
  .avl_addr                 (ddr3_avl_addr),          
  .avl_rdata_valid          (ddr3_avl_rdata_valid),   
  .avl_rdata                (ddr3_avl_rdata),         
  .avl_wdata                (128'd0),
  .avl_be                   (16'hFFFF),            
  .avl_read_req             (ddr3_avl_read_req),      
  .avl_write_req            (1'b0),
  .avl_size                 (ddr3_avl_size),          
  .local_init_done          (ddr3_local_init_done),   
  .local_cal_success        (ddr3_local_cal_success), 
  .local_cal_fail           (ddr3_local_cal_fail),    

  .oct_rzqin                (DDR3_RZQ));

endmodule
