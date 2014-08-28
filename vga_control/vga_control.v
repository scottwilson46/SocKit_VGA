module vga_control (
  input               vga_clk,
  input               vga_reset_n,

  output        [7:0] vga_r,
  output        [7:0] vga_g,
  output        [7:0] vga_b,

  input               test_pat,

  output              vga_hs,
  output              vga_vs,
  output              vga_blank_n,
  output              vga_sync_n,

  input               data_fifo_empty,
  input       [127:0] ddr_fifo_rd_data,
  output              vga_rd_valid,

  output reg          test_out

);

parameter IDLE     = 1'b0;
parameter STARTED  = 1'b1;

reg next_vga_state, vga_state;
reg next_vga_sync_reset, vga_sync_reset;
wire [1:0] next_vga_count;
reg  [1:0] vga_count;
wire [127:0] vga_data_shifted;
wire [7:0] vga_r_sync;
wire [7:0] vga_g_sync;
wire [7:0] vga_b_sync;
wire       pixel_valid;

always @(*)
begin
	next_vga_state = vga_state;
	next_vga_sync_reset = vga_sync_reset;
	case(vga_state)
	  IDLE:
	    if (~data_fifo_empty | test_pat)
	    begin
	    	next_vga_state = STARTED;
	    	next_vga_sync_reset = 1'b0;
        end	   
	  STARTED:
	    next_vga_state = STARTED;
	endcase
end

assign next_vga_count     = (pixel_valid) ? vga_count + 'd1 : vga_count;
assign vga_rd_valid       = (pixel_valid && (&vga_count));
 
assign vga_data_shifted   = (ddr_fifo_rd_data >> (vga_count * 32));

assign vga_r              = (test_pat) ? vga_r_sync : vga_data_shifted[7:0];
assign vga_g              = (test_pat) ? vga_g_sync : vga_data_shifted[15:8];
assign vga_b     	  = (test_pat) ? vga_b_sync : vga_data_shifted[23:16];

always @(posedge vga_clk or negedge vga_reset_n)
  if (!vga_reset_n)
  begin
  	vga_state      <= IDLE;
  	vga_sync_reset <= 1'b1;
  	vga_count      <= 2'd0;
  end
  else begin
  	vga_state      <= next_vga_state;
  	vga_sync_reset <= next_vga_sync_reset;
  	vga_count      <= next_vga_count;
  end


vga_sync i_vga_sync (
  .clk           (vga_clk),
  .reset         (vga_sync_reset),
  .hsync         (vga_hs),
  .vsync         (vga_vs),
  .r             (vga_r_sync),
  .g             (vga_g_sync),
  .b             (vga_b_sync),

  .pixel_valid   (pixel_valid)); 

always @(posedge vga_clk or posedge vga_sync_reset)
  if (vga_sync_reset)
    test_out     <= 1'b0;
  else if (vga_r != 'd255)
    test_out     <= 1'b1;

assign vga_sync_n = 1'b0;
assign vga_blank_n = 1'b1;

endmodule
