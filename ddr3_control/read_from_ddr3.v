module read_from_ddr3 #(parameter IMAGE_WIDTH  = 1280,
                        parameter IMAGE_HEIGHT = 1024) (
  input                    ddr3_clk,
  input                    ddr3_reset_n,
  input                    clk,
  input                    reset_n,

  input                    ddr3_rd_buffer0_empty,
  input                    ddr3_rd_buffer1_empty,
  output                   clear_buffer0_clk,
  output                   clear_buffer1_clk,
  input          [25:0]    ddr3_buffer0_offset,
  input          [25:0]    ddr3_buffer1_offset,

  input          [31:0]    test_addr,
  input                    test_rd,
  output reg    [127:0]    test_rd_data,
  output                   rd_finish_clk,

  input                    data_fifo_almost_full,

  input                    ddr3_avl_ready,
  output reg               ddr3_avl_burstbegin,
  output reg      [2:0]    ddr3_avl_size,
  output reg               ddr3_avl_read_req,
  output reg     [25:0]    ddr3_avl_addr,

  input                    ddr3_avl_read_data_valid,
  input         [127:0]    ddr3_avl_read_data


);

parameter IDLE                   = 3'd0;
parameter START_READ             = 3'd1;
parameter START_TEST_READ        = 3'd2;
parameter WAIT_FOR_DATA          = 3'd3;
parameter WAIT_FOR_FIFO_TO_EMPTY = 3'd4;

parameter MAX_COUNT = (((IMAGE_WIDTH*IMAGE_HEIGHT)>>2)-1);


reg   [3:0] next_state, state; 
reg  [25:0] next_ddr3_avl_addr;
reg         next_ddr3_avl_burstbegin;
reg         next_ddr3_avl_read_req; 
reg   [2:0] next_ddr3_avl_size;
reg  [23:0] next_transfer_count, transfer_count;

reg         next_clear_buffer0, clear_buffer0;
reg         next_clear_buffer1, clear_buffer1;
reg         next_buffer_sel, buffer_sel;
reg         next_rd_finish, rd_finish;
reg [127:0] next_test_rd_data;


always @(*)
begin
    next_state               = state;
    ddr3_avl_burstbegin      = 1'b0;
    ddr3_avl_read_req        = 1'b0;
    next_transfer_count      = transfer_count;
    next_buffer_sel          = buffer_sel;
    next_clear_buffer0       = 1'b0;
    next_clear_buffer1       = 1'b0;
    next_ddr3_avl_addr       = ddr3_avl_addr;
    next_test_rd_data        = test_rd_data;
    next_rd_finish           = 1'b0;
    next_ddr3_avl_size       = ddr3_avl_size;

    case (state)
        IDLE:
            if (test_rd)
            begin
                next_state          = START_TEST_READ;
                next_ddr3_avl_addr  = test_addr[25:0];
                next_ddr3_avl_size  = 3'b001;
            end
            else if (!ddr3_rd_buffer0_empty || !ddr3_rd_buffer1_empty)
            begin
                if (!ddr3_rd_buffer0_empty && (buffer_sel == 1'b0))
                    next_ddr3_avl_addr       = ddr3_buffer0_offset;
                else if (!ddr3_rd_buffer1_empty && (buffer_sel == 1'b1))
                    next_ddr3_avl_addr       = ddr3_buffer1_offset;
                next_state          = START_READ;
                next_ddr3_avl_size  = 3'b100;
            end

        START_TEST_READ:
        begin
            ddr3_avl_burstbegin = 1'b1;
            ddr3_avl_read_req   = 1'b1;

            if (ddr3_avl_ready)
                next_state          = WAIT_FOR_DATA;
        end

        WAIT_FOR_DATA:
            if (ddr3_avl_read_data_valid)
            begin
                next_test_rd_data   = ddr3_avl_read_data;
                next_rd_finish      = 1'b1;
                next_state          = IDLE;
            end

        START_READ:
        begin
            ddr3_avl_burstbegin = 1'b1;
            ddr3_avl_read_req   = 1'b1;

            if (ddr3_avl_ready)
                if (data_fifo_almost_full)
                    next_state      = WAIT_FOR_FIFO_TO_EMPTY;
                else if (transfer_count == MAX_COUNT)
                begin
                  if (~buffer_sel)
                  begin
                    if (!ddr3_rd_buffer1_empty) begin
                      next_buffer_sel = 1'b1;
                      next_clear_buffer0 = 1'b1;
                    end
                    else begin
                      next_buffer_sel = 1'b0;
                    end
                  end
                  else 
                  begin
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
                else
                begin
                    next_ddr3_avl_addr       = ddr3_avl_addr + 'd4;
                    next_transfer_count      = transfer_count + 'd1;
                end
        end
        WAIT_FOR_FIFO_TO_EMPTY:
            if (!data_fifo_almost_full)
                next_state = START_READ;
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

async_handshake i_async_handshake_rd_finish (
	.req_clk     (ddr3_clk),
	.ack_clk     (clk),
	.req_reset_n (ddr3_reset_n),
	.ack_reset_n (reset_n),
	.req_in      (rd_finish),
	.ack_out     (rd_finish_clk));

always @(posedge ddr3_clk or negedge ddr3_reset_n)
  if (!ddr3_reset_n)
  begin
    state                 <= IDLE;
    ddr3_avl_addr         <= 26'd0;
    ddr3_avl_size         <= 3'd0;
    transfer_count        <= 'd0;
    buffer_sel            <= 1'b0;
    clear_buffer0         <= 1'b0;
    clear_buffer1         <= 1'b0;
    test_rd_data          <= 128'd0;
    rd_finish             <= 1'b0;
  end
  else
  begin
    state                 <= next_state;
    ddr3_avl_addr         <= next_ddr3_avl_addr;
    ddr3_avl_size         <= next_ddr3_avl_size;
    transfer_count        <= next_transfer_count;
    buffer_sel            <= next_buffer_sel;
    clear_buffer0         <= next_clear_buffer0;
    clear_buffer1         <= next_clear_buffer1;
    test_rd_data          <= next_test_rd_data;
    rd_finish             <= next_rd_finish;
  end
 

endmodule
