# TCL File Generated by Component Editor 13.0
# Mon May 13 15:10:52 PDT 2013
# DO NOT MODIFY


# 
# AUDIO_IF "AUDIO_IF" v1.0
#  2013.05.13.15:10:52
# 
# 

# 
# request TCL package from ACDS 13.0
# 
package require -exact qsys 13.0


# 
# module AUDIO_IF
# 
set_module_property DESCRIPTION ""
set_module_property NAME top_no_ddr3
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Terasic Technologies Inc./SoCKit"
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME top_no_ddr3
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false

add_fileset quartus_synth QUARTUS_SYNTH "" "Quartus Synthesis"
set_fileset_property quartus_synth TOP_LEVEL top_no_ddr3
add_fileset_file top_no_ddr3.v         VERILOG PATH ../top/top_no_ddr3.v
add_fileset_file vga_control.v         VERILOG PATH ../vga_control/vga_control.v
add_fileset_file vga_hsync.v           VERILOG PATH ../vga_control/vga_hsync.v
add_fileset_file vga_sync.v            VERILOG PATH ../vga_control/vga_sync.v
add_fileset_file vga_vsync.v           VERILOG PATH ../vga_control/vga_vsync.v
add_fileset_file altera_pll_vga.v      VERILOG PATH ../vga_control/altera_pll_vga.v
add_fileset_file altera_pll_vga_0002.v VERILOG PATH ../vga_control/altera_pll_vga_0002.v
add_fileset_file read_from_ddr3.v      VERILOG PATH ../ddr3_control/read_from_ddr3.v
add_fileset_file write_to_ddr3.v       VERILOG PATH ../ddr3_control/write_to_ddr3.v
add_fileset_file ddr3_top.v            VERILOG PATH ../ddr3_control/ddr3_top.v
add_fileset_file ddr3_regs.v           VERILOG PATH ../ddr3_control/ddr3_regs.v
add_fileset_file async_fifo.v          VERILOG PATH ../common/async_fifo.v
add_fileset_file async_fifo_no_sa.v    VERILOG PATH ../common/async_fifo_no_sa.v
add_fileset_file async_fifo_memory.v   VERILOG PATH ../common/async_fifo_memory.v
add_fileset_file async_fifo_calc.v     VERILOG PATH ../common/async_fifo_calc.v
add_fileset_file async_handshake.v     VERILOG PATH ../common/async_handshake.v
add_fileset_file reset_sync.v          VERILOG PATH ../common/reset_sync.v

add_interface clk clock sink
set_interface_property clk clockRate 0
set_interface_property clk ENABLED true
add_interface_port clk clk clk Input 1

add_interface clk_50 clock sink
set_interface_property clk_50 clockRate 0
set_interface_property clk_50 ENABLED true
add_interface_port clk_50 clk_50 clk Input 1

add_interface ddr3_clk clock sink
set_interface_property ddr3_clk clockRate 0
set_interface_property ddr3_clk ENABLED true
add_interface_port ddr3_clk ddr3_clk clk Input 1

add_interface reset_n reset sink
set_interface_property reset_n associatedClock clk
set_interface_property reset_n synchronousEdges DEASSERT
set_interface_property reset_n ENABLED true
add_interface_port reset_n reset_n reset_n Input 1

add_interface avalon_slave avalon end
set_interface_property avalon_slave addressUnits WORDS
set_interface_property avalon_slave associatedClock clk
set_interface_property avalon_slave associatedReset reset_n
set_interface_property avalon_slave bitsPerSymbol 8
set_interface_property avalon_slave burstOnBurstBoundariesOnly false
set_interface_property avalon_slave burstcountUnits WORDS
set_interface_property avalon_slave explicitAddressSpan 0
set_interface_property avalon_slave holdTime 0
set_interface_property avalon_slave linewrapBursts false
set_interface_property avalon_slave maximumPendingReadTransactions 0
set_interface_property avalon_slave readLatency 0
set_interface_property avalon_slave readWaitTime 1
set_interface_property avalon_slave setupTime 0
set_interface_property avalon_slave timingUnits Cycles
set_interface_property avalon_slave writeWaitTime 0
set_interface_property avalon_slave ENABLED true
set_interface_property avalon_slave EXPORT_OF ""
set_interface_property avalon_slave PORT_NAME_MAP ""
set_interface_property avalon_slave SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave csr_addr  address Input 8
add_interface_port avalon_slave csr_read     read Input 1
add_interface_port avalon_slave csr_rd_data  readdata Output 32
add_interface_port avalon_slave csr_write    write Input 1
add_interface_port avalon_slave csr_wr_data  writedata Input 32
set_interface_assignment avalon_slave embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave embeddedsw.configuration.isPrintableDevice 0

add_interface ddr3_memory_con avalon start
#set_interface_property ddr3_memory_con addressAlignment NATIVE
set_interface_property ddr3_memory_con addressUnits WORDS
set_interface_property ddr3_memory_con associatedClock ddr3_clk  
set_interface_property ddr3_memory_con associatedReset reset_n
set_interface_property ddr3_memory_con bitsPerSymbol 8
set_interface_property ddr3_memory_con burstOnBurstBoundariesOnly false
set_interface_property ddr3_memory_con burstcountUnits WORDS
#set_interface_property ddr3_memory_con explicitAddressSpan 0
set_interface_property ddr3_memory_con holdTime 0
set_interface_property ddr3_memory_con linewrapBursts false
set_interface_property ddr3_memory_con maximumPendingReadTransactions 4
set_interface_property ddr3_memory_con readLatency 0
#set_interface_property ddr3_memory_con readWaitStates 0
set_interface_property ddr3_memory_con readWaitTime 0
set_interface_property ddr3_memory_con setupTime 0
set_interface_property ddr3_memory_con timingUnits Cycles
set_interface_property ddr3_memory_con writeWaitTime 0
set_interface_property ddr3_memory_con ENABLED true
set_interface_property ddr3_memory_con EXPORT_OF ""
set_interface_property ddr3_memory_con PORT_NAME_MAP ""
set_interface_property ddr3_memory_con SVD_ADDRESS_GROUP ""

add_interface_port ddr3_memory_con ddr3_avl_addr             address             Output 32
add_interface_port ddr3_memory_con ddr3_avl_read_req         read                Output 1
add_interface_port ddr3_memory_con ddr3_avl_write_req        write               Output 1
add_interface_port ddr3_memory_con ddr3_avl_wr_data          writedata           Output 128
add_interface_port ddr3_memory_con ddr3_avl_read_data        readdata            Input  128
add_interface_port ddr3_memory_con ddr3_avl_read_data_valid  readdatavalid       Input  1
add_interface_port ddr3_memory_con ddr3_avl_size             burstcount          Output 3
add_interface_port ddr3_memory_con ddr3_avl_burstbegin       beginbursttransfer  Output 1
add_interface_port ddr3_memory_con ddr3_avl_ready            waitrequest_n       Input 1
set_interface_assignment ddr3_memory_con embeddedsw.configuration.isFlash 0
set_interface_assignment ddr3_memory_con embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment ddr3_memory_con embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment ddr3_memory_con embeddedsw.configuration.isPrintableDevice 0

add_interface vga_r conduit end
set_interface_property vga_r associatedClock ""
set_interface_property vga_r associatedReset ""
set_interface_property vga_r ENABLED true
add_interface_port vga_r vga_r export Output 8

add_interface vga_g conduit end
set_interface_property vga_g associatedClock ""
set_interface_property vga_g associatedReset ""
set_interface_property vga_g ENABLED true
add_interface_port vga_g vga_g export Output 8

add_interface vga_b conduit end
set_interface_property vga_b associatedClock ""
set_interface_property vga_b associatedReset ""
set_interface_property vga_b ENABLED true
add_interface_port vga_b vga_b export Output 8

add_interface vga_hs conduit end
set_interface_property vga_hs associatedClock ""
set_interface_property vga_hs associatedReset ""
set_interface_property vga_hs ENABLED true
add_interface_port vga_hs vga_hs export Output 1

add_interface vga_vs conduit end
set_interface_property vga_vs associatedClock ""
set_interface_property vga_vs associatedReset ""
set_interface_property vga_vs ENABLED true
add_interface_port vga_vs vga_vs export Output 1

add_interface vga_blank_n conduit end
set_interface_property vga_blank_n associatedClock ""
set_interface_property vga_blank_n associatedReset ""
set_interface_property vga_blank_n ENABLED true
add_interface_port vga_blank_n vga_blank_n export Output 1

add_interface vga_sync_n conduit end
set_interface_property vga_sync_n associatedClock ""
set_interface_property vga_sync_n associatedReset ""
set_interface_property vga_sync_n ENABLED true
add_interface_port vga_sync_n vga_sync_n export Output 1

add_interface vga_clk conduit end
set_interface_property vga_clk associatedClock ""
set_interface_property vga_clk associatedReset ""
set_interface_property vga_clk ENABLED true
add_interface_port vga_clk vga_clk export Output 1

add_interface test_regs conduit end
set_interface_property test_regs associatedClock ""
set_interface_property test_regs associatedReset ""
set_interface_property test_regs ENABLED true
add_interface_port test_regs test_regs export Output 32

add_interface key_val conduit start
set_interface_property key_val associatedClock ""
set_interface_property key_val associatedReset ""
set_interface_property key_val ENABLED true
add_interface_port key_val key_val export Input 4 












