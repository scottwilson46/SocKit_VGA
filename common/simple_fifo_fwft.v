module simple_fifo_fwft #(parameter FIFO_PTR_DEPTH = 4, 
                          parameter DATA_SIZE = 32) (
  input                     CLK,
  input                     RSTN,

  input     [DATA_SIZE-1:0] DATA_IN,
  input                     WR_IN,

  output                    FIFO_FULL_OUT,
  output                    FIFO_EMPTY_OUT,

  output    [DATA_SIZE-1:0] DATA_OUT,
  input                     RD_IN
);

wire rd_pre;
reg  rd_valid;

simple_fifo #(.FIFO_PTR_DEPTH (FIFO_PTR_DEPTH),
              .DATA_SIZE      (DATA_SIZE)) i_simple_fifo (
  .CLK              (CLK),
  .RSTN             (RSTN),
  .DATA_IN          (DATA_IN),
  .WR_IN            (WR_IN),
  .FIFO_FULL_OUT    (FIFO_FULL_OUT),
  .FIFO_EMPTY_OUT   (empty_pre),
  .DATA_OUT         (DATA_OUT),
  .RD_IN            (rd_pre));

assign rd_pre         = ~empty_pre & (~rd_valid | RD_IN);
assign FIFO_EMPTY_OUT = ~rd_valid;

always @(posedge CLK or negedge RSTN)
  if (!RSTN)
    rd_valid <= 1'b0;
  else if (rd_pre)
    rd_valid <= 1'b1;
  else if (RD_IN)
    rd_valid <= 1'b0;

endmodule

