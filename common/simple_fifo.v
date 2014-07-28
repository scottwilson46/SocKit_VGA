module simple_fifo #(parameter FIFO_PTR_DEPTH = 4,
                     parameter DATA_SIZE =32) (
  input                        CLK,
  input                        RSTN,

  input        [DATA_SIZE-1:0] DATA_IN,
  input                        WR_IN,

  output reg                   FIFO_FULL_OUT,
  output reg                   FIFO_EMPTY_OUT,

  output reg   [DATA_SIZE-1:0] DATA_OUT,
  input                        RD_IN
);

parameter FIFO_SIZE = (1<<FIFO_PTR_DEPTH);

wire              [FIFO_PTR_DEPTH:0] next_wr_ptr;
reg               [FIFO_PTR_DEPTH:0] wr_ptr;

wire              [FIFO_PTR_DEPTH:0] next_rd_ptr;
reg               [FIFO_PTR_DEPTH:0] rd_ptr;

wire                                 next_fifo_full;
wire                                 next_fifo_empty;

reg                  [DATA_SIZE-1:0] fifo_store [0:FIFO_SIZE-1];
wire                 [DATA_SIZE-1:0] next_rd_data;

assign next_wr_ptr     = (WR_IN & ~FIFO_FULL_OUT) ? wr_ptr + 'd1 : 
                         wr_ptr;

assign next_fifo_full  = (next_wr_ptr[FIFO_PTR_DEPTH] ^ next_rd_ptr[FIFO_PTR_DEPTH]) &
                         (next_wr_ptr[FIFO_PTR_DEPTH-1:0] ==
                          next_rd_ptr[FIFO_PTR_DEPTH-1:0]);

assign next_rd_ptr     = (RD_IN & ~FIFO_EMPTY_OUT) ? rd_ptr + 'd1 :
                         rd_ptr;

assign next_fifo_empty = (next_wr_ptr == next_rd_ptr);

always @(posedge CLK)
begin
  if (WR_IN & ~FIFO_FULL_OUT)
    fifo_store[wr_ptr[FIFO_PTR_DEPTH-1:0]] <= DATA_IN;
end

assign next_rd_data = (RD_IN & ~FIFO_EMPTY_OUT) ? 
                      fifo_store[rd_ptr[FIFO_PTR_DEPTH-1:0]] :
                      DATA_OUT;                

always @(posedge CLK)
  DATA_OUT <= next_rd_data;

always @(posedge CLK or negedge RSTN)
  if (!RSTN)
  begin
    wr_ptr         <= 'd0;
    rd_ptr         <= 'd0;
    FIFO_FULL_OUT  <= 1'b0;
    FIFO_EMPTY_OUT <= 1'b1;
  end
  else 
  begin
    wr_ptr         <= next_wr_ptr;
    rd_ptr         <= next_rd_ptr;
    FIFO_FULL_OUT  <= next_fifo_full;
    FIFO_EMPTY_OUT <= next_fifo_empty;
  end


endmodule
