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

vga_top i_vga_top (
  .clk         (clk),
  .reset_n     (~reset));


initial
begin
  $dumpfile("new.vcd");
  $dumpvars();
  #500000000 $finish();
end

endmodule

