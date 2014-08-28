`timescale 1ns/1ps

module tb();

reg clk, reset;

initial
begin 
  clk = 1'b0;
  reset = 1'b0;

  #10 reset = 1'b1;
  #10 reset = 1'b0;

  while(1)
    #10 clk = ~clk;
end


altera_pll_vga i_pll (
  .refclk     (clk),
  .rst        (reset),

  .outclk_0   (vga_clk_int),
  .locked     (pll_locked));

vga_control i_vga_control (
  .vga_clk      (vga_clk_int),
  .vga_reset_n  (pll_locked),
  .vga_r        (),
  .vga_g        (),
  .vga_b        (),
  .test_pat     (1'b1),
  .vga_hs       (),
  .vga_vs       (),
  .vga_blank_n  (),
  .vga_sync_n   (),
  .data_fifo_empty (1'b1),
  .ddr_fifo_rd_data (128'd0),
  .test_out     ());

initial
begin
  $dumpfile("new.vcd");
  $dumpvars();
  #10000000 $finish;
end

endmodule
