module write_to_ddr3 (
  input                    ddr3_clk,
  input                    ddr3_reset_n,
  input                    clk,
  input                    reset_n,

  input          [31:0]    test_addr,
  input         [127:0]    test_wr_data,
  input                    test_wr,
  output                   wr_finish_clk,

  input                    ddr3_avl_ready,
  output reg               ddr3_avl_burstbegin,
  output          [2:0]    ddr3_avl_size,
  output reg               ddr3_avl_write_req,
  output reg    [127:0]    ddr3_avl_wr_data,
  output reg     [25:0]    ddr3_avl_addr,

  output         [3:0]     debug_out
);

parameter IDLE         = 4'd0;
parameter START_WRITE  = 4'd1;
parameter WRITE_FINISH = 4'd2;

assign ddr3_avl_size = 3'b001;

reg   [1:0]  next_state, state;
reg  [25:0]  next_ddr3_avl_addr;
reg [127:0]  next_ddr3_avl_wr_data;
reg          next_ddr3_avl_burstbegin;
reg          next_ddr3_avl_write_req;
reg          next_wr_finish, wr_finish;
reg next_test,test;

assign debug_out = {1'b0, state, test};

always @(*)
begin
    next_state               = state;
    next_ddr3_avl_burstbegin = 1'b0;
    next_ddr3_avl_write_req  = 1'b0;
    next_ddr3_avl_addr       = ddr3_avl_addr;
    next_ddr3_avl_wr_data    = ddr3_avl_wr_data;
    next_wr_finish           = 1'b0;
    next_test                = test;
    case(state)
        IDLE:
            if (test_wr)
            begin
                next_state = START_WRITE;
                next_ddr3_avl_burstbegin = 1'b1;
                next_ddr3_avl_write_req  = 1'b1;
                next_ddr3_avl_addr       = test_addr[25:0];
                next_ddr3_avl_wr_data    = test_wr_data; 
            end
        START_WRITE:
            if (!ddr3_avl_ready)
            begin
                next_ddr3_avl_burstbegin = 1'b1;
                next_ddr3_avl_write_req  = 1'b1;
            end
            else if (ddr3_avl_ready)
            begin
                next_state = WRITE_FINISH;
            end
	WRITE_FINISH:
	begin
	    next_state = IDLE;
            next_wr_finish = 1'b1;
            next_test = 1'b1;
	end
    endcase
end

async_handshake i_async_handshake_wr_finish (
	.req_clk     (ddr3_clk),
	.ack_clk     (clk),
	.req_reset_n (ddr3_reset_n),
	.ack_reset_n (reset_n),
	.req_in      (wr_finish),
	.ack_out     (wr_finish_clk));

always @(posedge ddr3_clk or negedge ddr3_reset_n)
    if (!ddr3_reset_n)
    begin
        state                <= IDLE;
        ddr3_avl_addr        <= 'd0;
        ddr3_avl_burstbegin  <= 1'b0;
        ddr3_avl_write_req   <= 1'b0;
        ddr3_avl_wr_data     <= 128'd0;
        wr_finish            <= 1'b0;
        test                 <= 1'b0;
    end
    else
    begin
        state                <= next_state;
        ddr3_avl_addr        <= next_ddr3_avl_addr;
        ddr3_avl_burstbegin  <= next_ddr3_avl_burstbegin;
        ddr3_avl_write_req   <= next_ddr3_avl_write_req;
        ddr3_avl_wr_data     <= next_ddr3_avl_wr_data;
        wr_finish            <= next_wr_finish;
        test                 <= next_test;
    end

endmodule
