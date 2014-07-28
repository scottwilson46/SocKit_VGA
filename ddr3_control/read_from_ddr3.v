module read_from_ddr3 #(parameter IMAGE_WIDTH  = 1280,
                        parameter IMAGE_HEIGHT = 1024) (
  input                    ddr3_clk,
  input                    reset_n,

  input                    ddr3_rd_buffer0_empty,
  input                    ddr3_rd_buffer1_empty,
  output                   clear_buffer0_clk,
  output                   clear_buffer1_clk,
  input          [25:0]    ddr3_buffer0_offset,
  input          [25:0]    ddr3_buffer1_offset,

  input                    data_fifo_almost_full,

  input                    ddr3_avl_ready,
  output reg               ddr3_avl_burstbegin,
  output          [2:0]    ddr3_avl_size,
  output reg               ddr3_avl_read_req,
  output reg     [25:0]    ddr3_avl_addr

);

parameter IDLE         = 2'd0;
parameter START_READ   = 2'd1;

assign ddr3_avl_size = 3'b100;

reg   [3:0] next_state, state; 
reg  [25:0] next_ddr3_avl_addr;
reg         next_ddr3_avl_burstbegin;
reg         next_ddr3_avl_read_req; 
reg  [23:0] next_transfer_count, transfer_count;

reg         next_clear_buffer0, clear_buffer0;
reg         next_clear_buffer1, clear_buffer1;
reg         next_buffer_sel, buffer_sel;

always @(*)
begin
  next_state               = state;
  next_ddr3_avl_burstbegin = 1'b0;
  next_ddr3_avl_read_req   = 1'b0;
  next_transfer_count      = transfer_count;
  next_buffer_sel          = buffer_sel;
  next_clear_buffer0       = 1'b0;
  next_clear_buffer1       = 1'b0;

  case (state)
    IDLE:
      if (!ddr3_rd_buffer0_empty || !ddr3_rd_buffer1_empty)
      begin
        if (!ddr3_rd_buffer0_empty && (buffer_sel == 1'b0))
          next_ddr3_avl_addr       = ddr3_buffer0_offset;
        else if (!ddr3_rd_buffer1_empty && (buffer_sel == 1'b1))
          next_ddr3_avl_addr       = ddr3_buffer1_offset;
        next_state = START_READ;
        next_ddr3_avl_burstbegin = 1'b1;
        next_ddr3_avl_read_req   = 1'b1;
        next_transfer_count      = 'd0;
      end

    START_READ:
      if (!ddr3_avl_ready)
      begin
        next_ddr3_avl_burstbegin = 1'b1;
        next_ddr3_avl_read_req   = 1'b1;
      end
      else if (ddr3_avl_ready)
      begin
        if (transfer_count == (((IMAGE_WIDTH*IMAGE_HEIGHT)>>2)-1))
        begin
          if (~buffer_sel)
            if (!ddr3_rd_buffer1_empty) begin
              next_buffer_sel = 1'b1;
              next_clear_buffer0 = 1'b1;
            end
            else begin
              next_buffer_sel = 1'b0;
            end
          else begin
            if (!ddr3_rd_buffer0_empty) begin
              next_buffer_sel = 1'b0;
              next_clear_buffer1 = 1'b1;
            end
            else begin
              next_buffer_sel = 1'b1;      
            end
          end
          next_state      = IDLE;
        end 
        else if (~data_fifo_almost_full) 
        begin
          next_ddr3_avl_addr       = ddr3_avl_addr + 'd4;
          next_ddr3_avl_burstbegin = 1'b1;
          next_ddr3_avl_read_req   = 1'b1;
          next_transfer_count      = transfer_count + 'd1;
        end
      end
  endcase
end

async_handshake i_async_handshake_clear0 (
	.req_clk     (ddr3_clk),
	.ack_clk     (clk),
	.req_reset_n (ddr3_reset_n),
	.ack_reset_n (reset_n),
	.req_in      (clear_buffer0),
	.ack_out     (clear_buffer0_clk));

async_handshake i_async_handshake_clear1 (
	.req_clk     (ddr3_clk),
	.ack_clk     (clk),
	.req_reset_n (ddr3_reset_n),
	.ack_reset_n (reset_n),
	.req_in      (clear_buffer1),
	.ack_out     (clear_buffer1_clk));

always @(posedge ddr3_clk or negedge reset_n)
  if (!reset_n)
  begin
    state                 <= IDLE;
    ddr3_avl_addr         <= 26'd0;
    ddr3_avl_burstbegin   <= 1'b0;
    ddr3_avl_read_req     <= 1'b0;
    transfer_count        <= 'd0;
    buffer_sel            <= 1'b0;
    clear_buffer0         <= 1'b0;
    clear_buffer1         <= 1'b0;
  end
  else
  begin
    state                 <= next_state;
    ddr3_avl_addr         <= next_ddr3_avl_addr;
    ddr3_avl_burstbegin   <= next_ddr3_avl_burstbegin;
    ddr3_avl_read_req     <= next_ddr3_avl_read_req;
    transfer_count        <= next_transfer_count;
    buffer_sel            <= next_buffer_sel;
    clear_buffer0         <= next_clear_buffer0;
    clear_buffer1         <= next_clear_buffer1;
  end
 

endmodule
