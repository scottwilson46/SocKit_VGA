module async_fifo_calc #(parameter fifo_data_size = 8, fifo_ptr_size = 8) 
(
  // Clocks and resets:
  input                                   clk,
  input                                   reset,

  // FIFO Input Signals
  input                                   update_valid,
  input      [fifo_ptr_size:0]            other_ptr_gray,
  
  // FIFO Output Signals
  output     [fifo_ptr_size-1:0]          mem_addr,
  output reg [fifo_ptr_size:0]            ptr_gray,
  output reg                              fifo_full,
  output reg                              fifo_empty,
  output reg [fifo_ptr_size:0]            fifo_depth_of);

  wire [fifo_ptr_size:0] next_fifo_counter;
  reg  [fifo_ptr_size:0] fifo_counter;
  reg  [fifo_ptr_size:0] next_ptr_gray;
  reg  [fifo_ptr_size:0] other_ptr_bin;
  reg  [fifo_ptr_size:0] other_ptr_bin_reg;
  reg  [fifo_ptr_size:0] other_ptr_gray_sync;
  reg  [fifo_ptr_size:0] other_ptr_gray_sync2;
  wire                   next_fifo_full;
  wire                   next_fifo_empty;
  wire [fifo_ptr_size:0] next_fifo_depth_of; 
  wire                   next_fifo_almost_full;  
  integer                i,j;   

  parameter fifo_size = 1<<fifo_ptr_size;

  assign mem_addr = fifo_counter[fifo_ptr_size-1:0];

  // FIFO Counter:
  assign next_fifo_counter = (update_valid) ? fifo_counter + 'd1 :
                             fifo_counter;

  // Convert the Binary Counter to Gray Code:
  always @(*)
  begin
    next_ptr_gray = next_fifo_counter;
    for (i=fifo_ptr_size;i>=1;i=i-1)
      next_ptr_gray[i-1] = next_fifo_counter[i] ^ next_fifo_counter[i-1];
  end

  // Convert the other pointer to Binary:
  always @(*)
  begin
    other_ptr_bin = other_ptr_gray_sync2;
    for (j=fifo_ptr_size;j>=1;j=j-1)
      other_ptr_bin[j-1] = other_ptr_bin[j] ^ other_ptr_gray_sync2[j-1];
  end

  assign next_fifo_full  = (next_fifo_counter[fifo_ptr_size] ^ 
                            other_ptr_bin[fifo_ptr_size]) &
                           (next_fifo_counter[fifo_ptr_size-1:0] ==
                            other_ptr_bin[fifo_ptr_size-1:0]);
  assign next_fifo_empty = (next_fifo_counter == other_ptr_bin);

  assign next_fifo_depth_of = (fifo_counter[fifo_ptr_size] ^
                               other_ptr_bin_reg[fifo_ptr_size]) ?
                              (fifo_size - other_ptr_bin_reg[fifo_ptr_size-1:0]) +
                              fifo_counter[fifo_ptr_size-1:0] :
                              (fifo_counter[fifo_ptr_size-1:0] - 
                               other_ptr_bin_reg[fifo_ptr_size-1:0]);

  always @(posedge clk or posedge reset)
    if (reset) 
    begin
      fifo_counter           <= 'd0;
      ptr_gray               <= 'd0;
      other_ptr_bin_reg      <= 'd0;
      other_ptr_gray_sync    <= 'd0;
      other_ptr_gray_sync2   <= 'd0;
      fifo_full              <= 1'b0; 
      fifo_empty             <= 1'b1;
      fifo_depth_of          <= 'd0;
    end
    else
    begin
      fifo_counter           <= next_fifo_counter;
      ptr_gray               <= next_ptr_gray;
      other_ptr_bin_reg      <= other_ptr_bin;
      other_ptr_gray_sync    <= other_ptr_gray;
      other_ptr_gray_sync2   <= other_ptr_gray_sync;
      fifo_full              <= next_fifo_full; 
      fifo_empty             <= next_fifo_empty;
      fifo_depth_of          <= next_fifo_depth_of;
    end

endmodule
