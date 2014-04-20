module read_from_ddr3 (
  input                    ddr3_clk,
  input                    reset_n,

  input         [127:0]    ddr3_avl_rdata,
  input                    ddr3_avl_rdata_valid,

  input                    ddr3_avl_ready,
  output reg               ddr3_avl_burstbegin,
  output          [2:0]    ddr3_avl_size,
  output reg               ddr3_avl_read_req,
  output reg     [25:0]    ddr3_avl_addr,

  output reg               ddr3_data_valid,

  input                    rd_valid,
  input          [9:0]     rd_addr,
  output reg  [1023:0]     ddr3_rd_data
);

parameter IDLE         = 2'd0;
parameter START_READ   = 2'd1;
parameter START_READ2  = 2'd2;

assign ddr3_avl_size = 3'b100;

reg   [3:0] next_state, state; 
reg  [25:0] next_ddr3_avl_addr;
reg         next_ddr3_avl_burstbegin;
reg         next_ddr3_avl_read_req; 
wire  [2:0] next_ddr3_data_count;
reg   [2:0] ddr3_data_count;
wire        next_ddr3_data_valid;
wire [1023:0]  next_ddr3_rd_data;

always @(*)
begin
  next_state               = state;
  next_ddr3_avl_addr       = ddr3_avl_addr;
  next_ddr3_avl_burstbegin = 1'b0;
  next_ddr3_avl_read_req   = 1'b0;
 
  case(state)
    IDLE:
      if (rd_valid)
      begin
        next_ddr3_avl_addr       = {rd_addr, 3'd0};
        next_ddr3_avl_burstbegin = 1'b1;
        next_ddr3_avl_read_req   = 1'b1;
        next_state               = START_READ;
      end

    START_READ:
    begin
      if (~ddr3_avl_ready)
      begin
        next_ddr3_avl_burstbegin = 1'b1;
        next_ddr3_avl_read_req   = 1'b1;
      end
      if (ddr3_avl_ready)
      begin
        next_state = START_READ2;
        next_ddr3_avl_burstbegin = 1'b1;
        next_ddr3_avl_read_req   = 1'b1;
        next_ddr3_avl_addr = ddr3_avl_addr + 26'd4;
      end
    end
 
    START_READ2:
    begin
      if (~ddr3_avl_ready)
      begin
        next_ddr3_avl_burstbegin = 1'b1;
        next_ddr3_avl_read_req   = 1'b1;
      end
      if (ddr3_avl_ready)
      begin
        next_state = IDLE;
      end
    end
  endcase
end

assign next_ddr3_data_count = (ddr3_avl_rdata_valid) ? ddr3_data_count + 'd1 :
                              ddr3_data_count;
assign next_ddr3_data_valid = (ddr3_data_count == 'd7) & ddr3_avl_rdata_valid;

assign next_ddr3_rd_data    = (ddr3_data_count == 'd0) ? ddr3_avl_rdata :
                              ddr3_rd_data | (ddr3_avl_rdata << (128*ddr3_data_count));

always @(posedge ddr3_clk or negedge reset_n)
  if (!reset_n)
  begin
    state                 <= IDLE;
    ddr3_avl_addr         <= 26'd0;
    ddr3_avl_burstbegin   <= 1'b0;
    ddr3_avl_read_req     <= 1'b0;
    ddr3_data_count       <= 3'd0;
    ddr3_data_valid       <= 1'b0;
    ddr3_rd_data          <= 1024'd0;
  end
  else
  begin
    state                 <= next_state;
    ddr3_avl_addr         <= next_ddr3_avl_addr;
    ddr3_avl_burstbegin   <= next_ddr3_avl_burstbegin;
    ddr3_avl_read_req     <= next_ddr3_avl_read_req;
    ddr3_data_count       <= next_ddr3_data_count;
    ddr3_data_valid       <= next_ddr3_data_valid;
    ddr3_rd_data          <= ddr3_avl_rdata_valid ? next_ddr3_rd_data : ddr3_rd_data;
  end
 


endmodule
