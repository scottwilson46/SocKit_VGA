module ddr3_regs (
  input                        clk,
  input                        ddr3_clk,
  input                        reset_n,
  input                        ddr3_reset_n,

  input                        csr_read,
  input                        csr_write,
  input       [7:0]            csr_addr,
  input      [31:0]            csr_wr_data,
  input      [31:0]            csr_rd_data,

  output                       ddr3_rd_buffer0_empty,
  output                       ddr3_rd_buffer1_empty,

  output reg [25:0]            ddr3_buffer0_offset,
  output reg [25:0]            ddr3_buffer1_offset,

  input                        clear_buffer0,
  input                        clear_buffer1

);


reg [25:0] next_ddr3_buffer0_offset;
reg [25:0] next_ddr3_buffer1_offset;
reg next_ddr3_buffer0_wr;
reg next_ddr3_buffer1_wr;
reg ddr3_buffer0_wr;
reg ddr3_buffer1_wr;
reg [31:0] next_csr_rd_data;
wire next_ddr3_buffer0_state;
wire next_ddr3_buffer1_state;
reg ddr3_buffer0_state;
reg ddr3_buffer1_state;


assign ddr3_rd_buffer0_empty = ~ddr3_buffer0_state;
assign ddr3_rd_buffer1_empty = ~ddr3_buffer1_state;

always @(*)
begin
	next_ddr3_buffer0_offset = ddr3_buffer0_offset;
	next_ddr3_buffer1_offset = ddr3_buffer1_offset;
	next_ddr3_buffer0_wr     = 1'b0;
	next_ddr3_buffer1_wr     = 1'b0;
	case(csr_addr)
		8'd00: next_ddr3_buffer0_offset = csr_wr_data;
		8'd01: next_ddr3_buffer1_offset = csr_wr_data;
		8'd02: next_ddr3_buffer0_wr     = csr_wr_data[0];
		8'd03: next_ddr3_buffer1_wr     = csr_wr_data[0];
	endcase

end

always @(*)
begin
	next_csr_rd_data = 32'd0;
    case(csr_addr)
      8'd00: next_csr_rd_data = ddr3_buffer0_offset;
      8'd01: next_csr_rd_data = ddr3_buffer1_offset;
      8'd02: next_csr_rd_data = {31'd0, ddr3_buffer0_state};
      8'd03: next_csr_rd_data = {31'd0, ddr3_buffer1_state};
    endcase
end

async_handshake i_async_handshake_set_full0 (
	.req_clk     (clk),
	.ack_clk     (ddr3_clk),
	.req_reset_n (reset_n),
	.ack_reset_n (ddr3_reset_n),
	.req_in      (ddr3_buffer0_wr),
	.ack_out     (ddr3_buffer0_wr_ddr3));

async_handshake i_async_handshake_set_full1 (
	.req_clk     (clk),
	.ack_clk     (ddr3_clk),
	.req_reset_n (reset_n),
	.ack_reset_n (ddr3_reset_n),
	.req_in      (ddr3_buffer1_wr),
	.ack_out     (ddr3_buffer1_wr_ddr3));

assign next_ddr3_buffer0_state = (ddr3_buffer0_wr_ddr3) ? 1'b1 :
	                             (clear_buffer0)        ? 1'b0 :
	                             ddr3_buffer0_state;

assign next_ddr3_buffer1_state = (ddr3_buffer1_wr_ddr3) ? 1'b1 :
	                             (clear_buffer1)        ? 1'b0 :
	                             ddr3_buffer1_state;

always @(posedge clk or negedge reset_n)
  if (!reset_n)
  begin
  	ddr3_buffer0_offset   <= 26'd0;
  	ddr3_buffer1_offset   <= 26'd0;
  	ddr3_buffer0_wr       <= 1'b0;
  	ddr3_buffer1_wr       <= 1'b0;
  end
  else begin
    ddr3_buffer0_offset   <= next_ddr3_buffer0_offset;
    ddr3_buffer1_offset   <= next_ddr3_buffer1_offset;
    ddr3_buffer0_wr       <= next_ddr3_buffer0_wr;
    ddr3_buffer1_wr       <= next_ddr3_buffer1_wr;
  end

always @(posedge ddr3_clk or negedge ddr3_reset_n)
  if (!ddr3_reset_n)
  begin
  	ddr3_buffer0_state    <= 1'b0;
  	ddr3_buffer1_state    <= 1'b0;
  end
  else begin
  	ddr3_buffer0_state    <= next_ddr3_buffer0_state;
  	ddr3_buffer1_state    <= next_ddr3_buffer1_state;
  end

endmodule

