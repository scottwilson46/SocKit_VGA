module ddr3_regs (
  input                        clk,
  input                        ddr3_clk,
  input                        reset_n,
  input                        ddr3_reset_n,

  input                        csr_read,
  input                        csr_write,
  input       [7:0]            csr_addr,
  input      [31:0]            csr_wr_data,
  output reg [31:0]            csr_rd_data,

  output                       ddr3_rd_buffer0_empty,
  output                       ddr3_rd_buffer1_empty,

  output reg [25:0]            ddr3_buffer0_offset,
  output reg [25:0]            ddr3_buffer1_offset,

  output reg [31:0]            test_regs,
  output reg [31:0]            test_addr,
  output reg [127:0]           test_wr_data,
  output                       test_wr_ddr3,

  input      [127:0]           test_rd_data,
  output                       test_rd_ddr3,

  input                        clear_buffer0,
  input                        clear_buffer1,
  input                        wr_finish,
  input                        rd_finish
);


reg [25:0] next_ddr3_buffer0_offset;
reg [25:0] next_ddr3_buffer1_offset;
reg next_ddr3_buffer0_wr;
reg next_ddr3_buffer1_wr;
reg ddr3_buffer0_wr;
reg ddr3_buffer1_wr;
wire ddr3_buffer0_wr_ddr3;
wire ddr3_buffer1_wr_ddr3;
reg [31:0] next_csr_rd_data;
wire next_ddr3_buffer0_state;
wire next_ddr3_buffer1_state;
reg         ddr3_buffer0_state;
reg         ddr3_buffer1_state;
reg [31:0]  next_test_regs;

reg [31:0]  next_test_addr;
reg [127:0] next_test_wr_data;
reg         next_test_wr;
reg         test_wr;

reg         next_test_rd;
reg         test_rd;

wire        next_ddr3_wr_state;
reg         ddr3_wr_state;

wire        next_ddr3_rd_state;
reg         ddr3_rd_state;

assign ddr3_rd_buffer0_empty = ~ddr3_buffer0_state;
assign ddr3_rd_buffer1_empty = ~ddr3_buffer1_state;

always @(*)
begin
	next_ddr3_buffer0_offset = ddr3_buffer0_offset;
	next_ddr3_buffer1_offset = ddr3_buffer1_offset;
	next_ddr3_buffer0_wr     = 1'b0;
	next_ddr3_buffer1_wr     = 1'b0;
        next_test_regs           = test_regs;
        next_test_addr           = test_addr;
        next_test_wr_data        = test_wr_data;
        next_test_wr             = 1'b0;
        next_test_rd             = 1'b0;
        if (csr_write)
	begin
	case(csr_addr)
		8'd00: next_ddr3_buffer0_offset    = csr_wr_data;
		8'd01: next_ddr3_buffer1_offset    = csr_wr_data;
		8'd02: next_ddr3_buffer0_wr        = csr_wr_data[0];
		8'd03: next_ddr3_buffer1_wr        = csr_wr_data[0];
                8'd04: next_test_regs              = csr_wr_data[31:0];
                8'd05: next_test_addr              = csr_wr_data[31:0];
                8'd06: next_test_wr_data[31:0]     = csr_wr_data[31:0];
                8'd07: next_test_wr_data[63:32]    = csr_wr_data[31:0];
                8'd08: next_test_wr_data[95:64]    = csr_wr_data[31:0];
                8'd09: next_test_wr_data[127:96]   = csr_wr_data[31:0];
                8'd10: begin next_test_wr                = csr_wr_data[0];     next_test_rd = csr_wr_data[1]; end
                
	endcase
	end
end

always @(*)
begin
    next_csr_rd_data = 32'd0;
    case(csr_addr)
      8'd00: next_csr_rd_data = ddr3_buffer0_offset;
      8'd01: next_csr_rd_data = ddr3_buffer1_offset;
      8'd02: next_csr_rd_data = {31'd0, ddr3_buffer0_state};
      8'd03: next_csr_rd_data = {31'd0, ddr3_buffer1_state};
      8'd04: next_csr_rd_data = test_regs;
      8'd05: next_csr_rd_data = test_addr;
      8'd06: next_csr_rd_data = test_wr_data[31:0];
      8'd07: next_csr_rd_data = test_wr_data[63:32];
      8'd08: next_csr_rd_data = test_wr_data[95:64];
      8'd09: next_csr_rd_data = test_wr_data[127:96];
      8'd10: next_csr_rd_data = {30'd0, ddr3_rd_state, ddr3_wr_state};
      8'd11: next_csr_rd_data = test_rd_data[31:0];
      8'd12: next_csr_rd_data = test_rd_data[63:32];
      8'd13: next_csr_rd_data = test_rd_data[95:64];
      8'd14: next_csr_rd_data = test_rd_data[127:96];
      8'd15: next_csr_rd_data = 32'hb00bb00b;
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

async_handshake i_async_handshake_set_test_wr (
        .req_clk     (clk),
        .ack_clk     (ddr3_clk),
        .req_reset_n (reset_n),
        .ack_reset_n (ddr3_reset_n),
        .req_in      (test_wr),
        .ack_out     (test_wr_ddr3));

async_handshake i_async_handshake_set_test_rd (
        .req_clk     (clk),
        .ack_clk     (ddr3_clk),
        .req_reset_n (reset_n),
        .ack_reset_n (ddr3_reset_n),
        .req_in      (test_rd),
        .ack_out     (test_rd_ddr3));

assign next_ddr3_buffer0_state = (ddr3_buffer0_wr_ddr3) ? 1'b1 :
	                             (clear_buffer0)        ? 1'b0 :
	                             ddr3_buffer0_state;

assign next_ddr3_buffer1_state = (ddr3_buffer1_wr_ddr3) ? 1'b1 :
	                             (clear_buffer1)        ? 1'b0 :
	                             ddr3_buffer1_state;

assign next_ddr3_wr_state      = (test_wr) ? 1'b1 :
                                 (wr_finish) ? 1'b0 :
			         ddr3_wr_state;

assign next_ddr3_rd_state      = (test_rd) ? 1'b1 :
                                 (rd_finish) ? 1'b0 :
			         ddr3_rd_state;


always @(posedge clk or negedge reset_n)
  if (!reset_n)
  begin
  	ddr3_buffer0_offset   <= 26'd0;
  	ddr3_buffer1_offset   <= 26'd0;
  	ddr3_buffer0_wr       <= 1'b0;
  	ddr3_buffer1_wr       <= 1'b0;
        test_regs             <= 32'd0;
        test_addr             <= 32'd0;
        test_wr_data          <= 128'd0;
        test_wr               <= 1'b0;
        test_rd               <= 1'b0;
	csr_rd_data           <= 32'd0;
  end
  else begin
    ddr3_buffer0_offset   <= next_ddr3_buffer0_offset;
    ddr3_buffer1_offset   <= next_ddr3_buffer1_offset;
    ddr3_buffer0_wr       <= next_ddr3_buffer0_wr;
    ddr3_buffer1_wr       <= next_ddr3_buffer1_wr;
    test_regs             <= next_test_regs;
    test_wr               <= next_test_wr;
    test_rd               <= next_test_rd;
    test_wr_data          <= next_test_wr_data;
    test_addr             <= next_test_addr;
    csr_rd_data           <= (csr_read ? next_csr_rd_data : csr_rd_data);
  end

always @(posedge ddr3_clk or negedge ddr3_reset_n)
  if (!ddr3_reset_n)
  begin
  	ddr3_buffer0_state    <= 1'b0;
  	ddr3_buffer1_state    <= 1'b0;
	ddr3_wr_state         <= 1'b0;
        ddr3_rd_state         <= 1'b0;
  end
  else begin
  	ddr3_buffer0_state    <= next_ddr3_buffer0_state;
  	ddr3_buffer1_state    <= next_ddr3_buffer1_state;
	ddr3_wr_state         <= next_ddr3_wr_state;
        ddr3_rd_state         <= next_ddr3_rd_state;
  end

endmodule

