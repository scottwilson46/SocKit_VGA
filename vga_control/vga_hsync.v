module vga_hsync #(parameter FRONT   = 48,
                   parameter BACK    = 248,
                   parameter SYNC    = 112,
                   parameter VISIBLE = 1280) (
  input            clk,
  input            reset,

  output reg       hsync,
  output reg       hpixel_valid,
  output reg       update_vsync
);

parameter IDLE           = 3'd0;
parameter SYNC_STATE     = 3'd1;
parameter BACK_STATE     = 3'd2;
parameter VISIBLE_STATE  = 3'd3;
parameter FRONT_STATE    = 3'd4;

reg [2:0]  next_state, state;
reg [15:0] next_pixel_count, pixel_count;
reg        next_hsync;
reg        next_hpixel_valid;
reg        next_update_vsync;

always @(*)
begin
  next_pixel_count  = pixel_count;
  next_state        = state;
  next_hsync        = hsync;
  next_hpixel_valid = hpixel_valid;
  next_update_vsync = 1'b0;
  case(state)
    SYNC_STATE: 
      if (pixel_count == SYNC-1)
      begin
        next_state       = BACK_STATE;
        next_pixel_count = 'd0;
        next_hsync       = 1'b1;
      end
      else
        next_pixel_count = pixel_count + 'd1;
    BACK_STATE:
      if (pixel_count == BACK-1)
      begin
        next_state        = VISIBLE_STATE;
        next_pixel_count  = 'd0;
        next_hpixel_valid = 1'b1;
      end
      else 
        next_pixel_count = pixel_count + 'd1;
    VISIBLE_STATE:
      if (pixel_count == VISIBLE-1)
      begin
        next_state        = FRONT_STATE;
        next_pixel_count  = 'd0;
        next_hpixel_valid = 1'b0;
      end
      else
        next_pixel_count = pixel_count + 'd1;
    FRONT_STATE:
      if (pixel_count == FRONT-1)
      begin
        next_state        = SYNC_STATE;
        next_pixel_count  = 'd0;
        next_update_vsync = 1'b1;
        next_hsync        = 1'b0;
      end
      else
        next_pixel_count = pixel_count + 'd1;
  endcase
end

always @(posedge clk or posedge reset)
  if (reset)
  begin
    state        <= SYNC_STATE;
    pixel_count  <= 'd0;
    hpixel_valid <= 1'b0;
    hsync        <= 1'b0;
    update_vsync <= 1'b0;
  end
  else 
  begin
    state        <= next_state;
    pixel_count  <= next_pixel_count;
    hpixel_valid <= next_hpixel_valid;
    hsync        <= next_hsync;
    update_vsync <= next_update_vsync;
  end

endmodule
