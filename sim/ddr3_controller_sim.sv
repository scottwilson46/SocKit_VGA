module ddr3_controller_sim #(parameter DEBUG = 0) (

input          sodimm1_ddr3_avl_clk,
input          sodimm1_ddr3_avl_reset_n,
output         sodimm1_ddr3_avl_ready,
input          sodimm1_ddr3_avl_burstbegin,
input  [25:0]  sodimm1_ddr3_avl_addr,
output         sodimm1_ddr3_avl_rdata_valid,
output [127:0] sodimm1_ddr3_avl_rdata,
input  [127:0] sodimm1_ddr3_avl_wdata,
input          sodimm1_ddr3_avl_read_req,
input          sodimm1_ddr3_avl_write_req,
input  [2:0]   sodimm1_ddr3_avl_size

);

parameter  IDLE                 = 4'd0;
parameter  WAIT_FOR_A_BIT       = 4'd1;
parameter  START_RD             = 4'd2;
parameter  OTHER_CYCLES         = 4'd3;

reg [3:0] next_wr_state, wr_state;
reg [3:0] next_rd_state, rd_state;

reg [127:0] ram [0:16384];

reg [25:0] next_wr_addr, wr_addr;
reg [2:0]  next_burst_size, burst_size;

reg [5:0]  next_rd_delay, rd_delay;
reg [25:0] next_rd_addr, rd_addr;
reg [2:0]  next_rd_size, rd_size;
reg [127:0] rd_data;
reg rd_data_valid;
reg rd_fifo_pop;
wire [31:0] rd_fifo_data;
wire rd_fifo_empty;
wire rd_fifo_full;

reg sodimm1_ddr3_avl_ready_int;

assign sodimm1_ddr3_avl_ready = sodimm1_ddr3_avl_ready_int & ~rd_fifo_full;

assign sodimm1_ddr3_avl_rdata   = rd_data;
assign sodimm1_ddr3_avl_rdata_valid = rd_data_valid;

always @(posedge sodimm1_ddr3_avl_clk or negedge sodimm1_ddr3_avl_reset_n)
  if (!sodimm1_ddr3_avl_reset_n)
    sodimm1_ddr3_avl_ready_int <= 1'b0;
  else
    sodimm1_ddr3_avl_ready_int <= $random % 4;


always @(posedge sodimm1_ddr3_avl_clk or negedge sodimm1_ddr3_avl_reset_n)
  if (!sodimm1_ddr3_avl_reset_n)
  begin
  end
  else
  begin
    if (wr_state == IDLE && sodimm1_ddr3_avl_ready && sodimm1_ddr3_avl_write_req)
    begin
      ram[sodimm1_ddr3_avl_addr] = sodimm1_ddr3_avl_wdata;
      if (DEBUG)
        $display("WriteDDR3: %x=%x", sodimm1_ddr3_avl_addr, sodimm1_ddr3_avl_wdata);
    end
    else if (wr_state == OTHER_CYCLES && sodimm1_ddr3_avl_ready)
    begin
      ram[wr_addr] = sodimm1_ddr3_avl_wdata;
      if (DEBUG)
        $display("WriteDDR3: %x=%x", wr_addr, sodimm1_ddr3_avl_wdata);
    end
  end

always @(*)
begin

  next_wr_addr = wr_addr;
  next_burst_size = burst_size;
  next_wr_state = wr_state;
  case(wr_state)

    IDLE:
      if (sodimm1_ddr3_avl_write_req && sodimm1_ddr3_avl_burstbegin && sodimm1_ddr3_avl_ready)
      begin
        next_wr_addr    = sodimm1_ddr3_avl_addr + 'd1;
        next_burst_size = sodimm1_ddr3_avl_size - 'd1;

        if ((sodimm1_ddr3_avl_size - 'd1) > 0)
        begin
          next_wr_state = OTHER_CYCLES;
        end
      end

    OTHER_CYCLES:
    begin
      if (burst_size > 0)
      begin
        if (sodimm1_ddr3_avl_ready)
        begin
          next_burst_size       = burst_size - 'd1;
          next_wr_addr          = wr_addr + 'd1;
          if (burst_size == 1)
            next_wr_state = IDLE;
        end
      end
    end
  endcase
end


simple_fifo_fwft #(.FIFO_PTR_DEPTH (4)) i_simple_fifo_fwft (
  .CLK                (sodimm1_ddr3_avl_clk),
  .RSTN               (sodimm1_ddr3_avl_reset_n),
  .DATA_IN            ({3'd0, sodimm1_ddr3_avl_size, sodimm1_ddr3_avl_addr}),
  .WR_IN              (sodimm1_ddr3_avl_read_req & sodimm1_ddr3_avl_ready),
  .RD_IN              (rd_fifo_pop),
  .DATA_OUT           (rd_fifo_data),
  .FIFO_EMPTY_OUT     (rd_fifo_empty),
  .FIFO_FULL_OUT      (rd_fifo_full));

always @(*)
begin
  next_rd_state = rd_state;
  next_rd_delay = rd_delay;
  next_rd_addr  = rd_addr;
  next_rd_size  = rd_size;
  rd_fifo_pop   = 1'b0;
  case(rd_state)

    IDLE:
      if (~rd_fifo_empty)
      begin
        next_rd_state = START_RD;
      end
    START_RD:
    begin
      next_rd_addr = rd_fifo_data[25:0];
      next_rd_size = rd_fifo_data[29:26];
      //rd_data = ram[rd_addr];

      rd_fifo_pop = 1'b1;

      next_rd_state = OTHER_CYCLES;

    end
    OTHER_CYCLES:
    begin

      if (rd_size > 1)
      begin
        //rd_data = ram[rd_addr];

        next_rd_addr = rd_addr + 'd1;
        next_rd_size = rd_size - 'd1;
      end
      else
        next_rd_state = IDLE;
    end
  endcase
end

always @(posedge sodimm1_ddr3_avl_clk or negedge sodimm1_ddr3_avl_reset_n)
  if (!sodimm1_ddr3_avl_reset_n)
  begin
    rd_data_valid = 1'b0;
  end
  else
  begin
    if (rd_state == OTHER_CYCLES)
    begin
      rd_data_valid <= 1'b1;
      rd_data <= ram[rd_addr];
      if (DEBUG)
        $display("ReadDDR3 : %x=%x", rd_addr, ram[rd_addr]);
    end
    else
      rd_data_valid <= 1'b0;
  end

always @(posedge sodimm1_ddr3_avl_clk or negedge sodimm1_ddr3_avl_reset_n)
  if (!sodimm1_ddr3_avl_reset_n)
  begin
    wr_state       <= IDLE;
    rd_state       <= IDLE;
    wr_addr        <= 'd0;
    burst_size     <= 'd0;
    rd_delay       <= 'd0;
    rd_addr        <= 'd0;
    rd_size        <= 'd0;
  end
  else
  begin
    wr_state       <= next_wr_state;
    rd_state       <= next_rd_state;
    wr_addr        <= next_wr_addr;
    burst_size     <= next_burst_size;
    rd_delay       <= next_rd_delay;
    rd_addr        <= next_rd_addr;
    rd_size        <= next_rd_size;
  end

endmodule
