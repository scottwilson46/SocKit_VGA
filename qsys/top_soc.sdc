create_clock -period 10 [get_ports clk_bot1]
create_clock -period 6  [get_ports clk_top1]
create_clock -period 20 [get_ports clk_50m_fpga]

set_false_path -fr i_qsys|mem_if_ddr3_emif_0|pll0|pll_afi_clk -to clk_bot1
