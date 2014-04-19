module vga_top (

  input           clk,
  input           reset_n,

  output    [7:0] vga_r,
  output    [7:0] vga_g,
  output    [7:0] vga_b,

  output          LED,

  output          vga_clk,
  output          vga_hs,
  output          vga_vs,
  output          vga_blank_n,
  output          vga_sync_n);

reg reset_n_sync0;
reg reset_n_sync1;
reg reset_n_sync2;
reg [31:0] count;

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

// Instantiate PLL:
altera_pll_vga i_pll (
  .refclk     (clk),
  .rst        (~reset_n_sync2),

  .outclk_0   (vga_clk_int),
  .locked     (pll_locked));

assign vga_sync_n = 1'b0;
assign vga_blank_n = 1'b1;
assign vga_clk    = vga_clk_int;

vga_sync i_vga_sync (
  .clk           (vga_clk),
  .reset         (~pll_locked),
  .hsync         (vga_hs),
  .vsync         (vga_vs),
  .r             (vga_r),
  .g             (vga_g),
  .b             (vga_b),

  .pixel_valid   ()); //vga_blank_n));

assign LED = count[24];

always @(posedge vga_clk or negedge pll_locked)
  if (!pll_locked)
    count <= 32'd0;
  else
    count <= count + 'd1;

endmodule    
