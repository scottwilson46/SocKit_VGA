module top_soc (

  input                    clk_top1,     // 156.25MHz
  input                    clk_bot1,     // 100MHz
  input                    clk_50m_fpga,

  inout                    hps_0_hps_io_hps_io_gpio_inst_GPIO09,
  inout                    hps_0_hps_io_hps_io_gpio_inst_GPIO35,
  inout                    hps_0_hps_io_hps_io_gpio_inst_GPIO48,
  inout                    hps_0_hps_io_hps_io_gpio_inst_GPIO53,
  inout                    hps_0_hps_io_hps_io_gpio_inst_GPIO54,
  inout                    hps_0_hps_io_hps_io_gpio_inst_GPIO55,
  inout                    hps_0_hps_io_hps_io_gpio_inst_GPIO56,
  inout                    hps_0_hps_io_hps_io_gpio_inst_GPIO61,
  inout                    hps_0_hps_io_hps_io_gpio_inst_GPIO62,
  inout                    hps_0_hps_io_hps_io_gpio_inst_GPIO00,

  output          [14:0]   HSP_DDR3_A,      
  output          [2:0]    HSP_DDR3_BA,     
  output                   HSP_DDR3_CK,     
  output                   HSP_DDR3_CK_N,   
  output                   HSP_DDR3_CKE,    
  output                   HSP_DDR3_CS_N,   
  output                   HSP_DDR3_RAS_N,  
  output                   HSP_DDR3_CAS_N,  
  output                   HSP_DDR3_WE_N,   
  output                   HSP_DDR3_RESET_N,
  inout           [31:0]   HSP_DDR3_DQ,     
  inout           [3:0]    HSP_DDR3_DQS,    
  inout           [3:0]    HSP_DDR3_DQS_N,  
  output                   HSP_DDR3_ODT,    
  output          [3:0]    HSP_DDR3_DM,     
  input                    HSP_DDR3_RZQ,

  output          [14:0]   DDR3_A,
  output          [2:0]    DDR3_BA,
  output                   DDR3_CAS_n,
  output                   DDR3_CKE,
  output                   DDR3_CK_n,
  output                   DDR3_CK,
  output                   DDR3_CS_n,
  output          [3:0]    DDR3_DM,
  inout           [31:0]   DDR3_DQ,
  inout           [3:0]    DDR3_DQS_n,
  inout           [3:0]    DDR3_DQS,
  output                   DDR3_ODT,
  output                   DDR3_RAS_n,
  output                   DDR3_RESET_n,
  input                    DDR3_RZQ,
  output                   DDR3_WE_n,

  output          [7:0]    vga_r,
  output          [7:0]    vga_g,
  output          [7:0]    vga_b,

  output                   vga_clk,
  output                   vga_hs,
  output                   vga_vs,
  output                   vga_blank_n,
  output                   vga_sync_n,
  
  output          [3:0]    LED,
  input           [3:0]    KEY
);

wire hps_fpga_reset_n;
wire [31:0] test_regs;
assign LED = {1'b0, init_done, cal_success, cal_fail}; //test_regs[3:0];

top_qsys i_qsys (

  .clk_clk                                       (clk_bot1),
  .clk_50_clk                                    (clk_50m_fpga),
  .reset_reset_n                                 (hps_fpga_reset_n),
  .reset_50_reset_n                              (hps_fpga_reset_n),

  .hps_0_hps_io_hps_io_gpio_inst_GPIO09          (hps_0_hps_io_hps_io_gpio_inst_GPIO09),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO35          (hps_0_hps_io_hps_io_gpio_inst_GPIO35),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO48          (hps_0_hps_io_hps_io_gpio_inst_GPIO48),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO53          (hps_0_hps_io_hps_io_gpio_inst_GPIO53),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO54          (hps_0_hps_io_hps_io_gpio_inst_GPIO54),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO55          (hps_0_hps_io_hps_io_gpio_inst_GPIO55),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO56          (hps_0_hps_io_hps_io_gpio_inst_GPIO56),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO61          (hps_0_hps_io_hps_io_gpio_inst_GPIO61),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO62          (hps_0_hps_io_hps_io_gpio_inst_GPIO62),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO00          (hps_0_hps_io_hps_io_gpio_inst_GPIO00),

  .memory_mem_a                                  (HSP_DDR3_A),      
  .memory_mem_ba                                 (HSP_DDR3_BA),     
  .memory_mem_ck                                 (HSP_DDR3_CK),     
  .memory_mem_ck_n                               (HSP_DDR3_CK_N),   
  .memory_mem_cke                                (HSP_DDR3_CKE),    
  .memory_mem_cs_n                               (HSP_DDR3_CS_N),   
  .memory_mem_dm                                 (HSP_DDR3_DM),     
  .memory_mem_ras_n                              (HSP_DDR3_RAS_N),  
  .memory_mem_cas_n                              (HSP_DDR3_CAS_N),  
  .memory_mem_we_n                               (HSP_DDR3_WE_N),   
  .memory_mem_reset_n                            (HSP_DDR3_RESET_N),
  .memory_mem_dq                                 (HSP_DDR3_DQ),     
  .memory_mem_dqs                                (HSP_DDR3_DQS),    
  .memory_mem_dqs_n                              (HSP_DDR3_DQS_N),  
  .memory_mem_odt                                (HSP_DDR3_ODT),    
  .memory_oct_rzqin                              (HSP_DDR3_RZQ),

  .memory_1_mem_a                                (DDR3_A),      
  .memory_1_mem_ba                               (DDR3_BA),     
  .memory_1_mem_ck                               (DDR3_CK),   
  .memory_1_mem_ck_n                             (DDR3_CK_n),   
  .memory_1_mem_cke                              (DDR3_CKE),    
  .memory_1_mem_cs_n                             (DDR3_CS_n),   
  .memory_1_mem_dm                               (DDR3_DM),     
  .memory_1_mem_ras_n                            (DDR3_RAS_n),  
  .memory_1_mem_cas_n                            (DDR3_CAS_n),  
  .memory_1_mem_we_n                             (DDR3_WE_n),   
  .memory_1_mem_reset_n                          (DDR3_RESET_n),
  .memory_1_mem_dq                               (DDR3_DQ),                                          
  .memory_1_mem_dqs                              (DDR3_DQS),                   
  .memory_1_mem_dqs_n                            (DDR3_DQS_n),                   
  .memory_1_mem_odt                              (DDR3_ODT),                     
  .oct_rzqin                                     (DDR3_RZQ),                     	
 
  .mem_if_ddr3_emif_0_pll_ref_clk_clk            (clk_top1),
  .mem_if_ddr3_emif_0_status_local_init_done     (init_done),
  .mem_if_ddr3_emif_0_status_local_cal_success   (cal_success),
  .mem_if_ddr3_emif_0_status_local_cal_fail      (cal_fail),
        
  .hps_0_h2f_reset_reset_n                       (hps_fpga_reset_n),

  .top_no_ddr3_0_vga_r_export                    (vga_r),
  .top_no_ddr3_0_vga_g_export                    (vga_g),
  .top_no_ddr3_0_vga_b_export                    (vga_b),
  .top_no_ddr3_0_vga_hs_export                   (vga_hs),
  .top_no_ddr3_0_vga_vs_export                   (vga_vs),
  .top_no_ddr3_0_vga_blank_n_export              (vga_blank_n),
  .top_no_ddr3_0_vga_sync_n_export               (vga_sync_n),
  .top_no_ddr3_0_vga_clk_export                  (vga_clk),

  .top_no_ddr3_0_test_regs_export                (test_regs),
  .top_no_ddr3_0_key_val_export                  (KEY));

endmodule

