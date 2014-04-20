module vga_sync (

  input          clk,
  input          reset,

  output         hsync,
  output         vsync,

  output [7:0]   r,
  output [7:0]   g,
  output [7:0]   b,

  output         pixel_valid
);

wire hpixel_valid;
wire vpixel_valid;

reg [15:0] x_count, y_count;

assign pixel_valid = hpixel_valid & vpixel_valid;

assign r = (x_count[5] & y_count[5]) ? 8'd255 : 8'd0;
assign g = (x_count[5] & y_count[5]) ? 8'd255 : 8'd0;
assign b = (x_count[5] & y_count[5]) ? 8'd255 : 8'd0;

vga_hsync i_vga_hsync (
  .clk          (clk),
  .reset        (reset),
  .hsync        (hsync),
  .hpixel_valid (hpixel_valid),
  .update_vsync (update_vsync));

vga_vsync i_vga_vsync (
  .clk          (clk),
  .reset        (reset),
  .update_vsync (update_vsync),
  .vsync        (vsync),
  .vpixel_valid (vpixel_valid));

always @(posedge clk or posedge reset)
  if (reset)
  begin
    x_count   <= 'd0;
    y_count   <= 'd0;
  end
  else 
  begin
    x_count   <= update_vsync ? 'd0 : (hpixel_valid) ? x_count + 'd1 : x_count;
    y_count   <= (y_count == 'd1023 & update_vsync) ? 'd0 : (update_vsync && vpixel_valid) ? y_count + 'd1 : y_count;
  end
endmodule
