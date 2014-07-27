module write_to_ddr3 (
  input                    ddr3_clk,
  input                    reset_n,

  input          [31:0]    test_addr,
  input          [31:0]    test_wr_data,
  input                    test_wr,

  input                    ddr3_avl_ready,
  output reg               ddr3_avl_burstbegin,
  output          [2:0]    ddr3_avl_size,
  output reg               ddr3_avl_write_req,
  output reg    [127:0]    ddr3_avl_wr_data,
  output reg     [25:0]    ddr3_avl_addr
);

parameter IDLE        = 2'd0;
parameter START_WRITE = 2'd1;

assign ddr3_avl_size = 3'b100;

reg   [1:0]  next_state, state;
reg  [25:0]  next_ddr3_avl_addr;
reg [127:0]  next_ddr3_avl_wr_data;
reg          next_ddr3_avl_burstbegin;
reg          next_ddr3_avl_write_req;

always @(*)
begin
    next_state               = state;
    next_ddr3_avl_burstbegin = 1'b0;
    next_ddr3_avl_write_req  = 1'b0;
    next_ddr3_avl_addr       = ddr3_avl_addr;
    next_ddr3_avl_wr_data    = ddr3_avl_wr_data;
    case(state)
        IDLE:
            if (test_wr)
            begin
                next_state = START_WRITE;
                next_ddr3_avl_burstbegin = 1'b1;
                next_ddr3_avl_write_req  = 1'b1;
                next_ddr3_avl_addr       = test_addr[25:0];
                next_ddr3_avl_wr_data    = {96'd0, test_wr_data}; 
            end
        START_WRITE:
            if (!ddr3_avl_ready)
            begin
                next_ddr3_avl_burstbegin = 1'b1;
                next_ddr3_avl_write_req  = 1'b1;
            end
            else if (ddr3_avl_ready)
            begin
                next_state = IDLE;
            end
    endcase
end

always @(posedge ddr3_clk or negedge reset_n)
    if (!reset_n)
    begin
        state                <= IDLE;
        ddr3_avl_addr        <= 'd0;
        ddr3_avl_burstbegin  <= 1'b0;
        ddr3_avl_write_req   <= 1'b0;
        ddr3_avl_wr_data     <= 128'd0;
    end
    else
    begin
        state                <= next_state;
        ddr3_avl_addr        <= next_ddr3_avl_addr;
        ddr3_avl_burstbegin  <= next_ddr3_avl_burstbegin;
        ddr3_avl_write_req   <= next_ddr3_avl_write_req;
        ddr3_avl_wr_data     <= next_ddr3_avl_wr_data;
    end

endmodule
