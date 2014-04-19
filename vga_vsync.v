module vga_vsync #(parameter FRONT   = 1,
                   parameter BACK    = 38,
                   parameter SYNC    = 3,
                   parameter VISIBLE = 1024) (
  input            clk,
  input            reset,
  input            update_vsync,

  output reg       vsync,
  output reg       vpixel_valid
);

parameter IDLE           = 3'd0;
parameter SYNC_STATE     = 3'd1;
parameter BACK_STATE     = 3'd2;
parameter VISIBLE_STATE  = 3'd3;
parameter FRONT_STATE    = 3'd4;

reg [2:0]  next_state, state;
reg [15:0] next_pixel_count, pixel_count;
reg        next_vsync;
reg        next_vpixel_valid;

always @(*)
begin
  next_pixel_count  = pixel_count;
  next_state        = state;
  next_vsync        = vsync;
  next_vpixel_valid = vpixel_valid;
  case(state)
    SYNC_STATE: 
      if (pixel_count == SYNC-1)
      begin
        next_state       = BACK_STATE;
        next_pixel_count = 'd0;
        next_vsync       = 1'b1;
      end
      else
        next_pixel_count = pixel_count + 'd1;
    BACK_STATE:
      if (pixel_count == BACK-1)
      begin
        next_state        = VISIBLE_STATE;
        next_pixel_count  = 'd0;
        next_vpixel_valid = 1'b1;
      end
      else 
        next_pixel_count = pixel_count + 'd1;
    VISIBLE_STATE:
      if (pixel_count == VISIBLE-1)
      begin
        next_state        = FRONT_STATE;
        next_pixel_count  = 'd0;
        next_vpixel_valid = 1'b0;
      end
      else
        next_pixel_count = pixel_count + 'd1;
    FRONT_STATE:
      if (pixel_count == FRONT-1)
      begin
        next_state       = SYNC_STATE;
        next_pixel_count = 'd0;
        next_vsync       = 1'b0;
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
    vpixel_valid <= 1'b0;
    vsync        <= 1'b0;
  end
  else if (update_vsync)
  begin
    state        <= next_state;
    pixel_count  <= next_pixel_count;
    vpixel_valid <= next_vpixel_valid;
    vsync        <= next_vsync;
  end

endmodule
