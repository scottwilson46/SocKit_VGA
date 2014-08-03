module csr_access #(parameter CSR_FILE = "regs.txt") (

  input                clk,
  input                reset_n,

  output reg    [31:0] csr_wr_data,
  output reg     [7:0] csr_address,
  output reg           csr_write,
  output reg           csr_read,
  input         [31:0] csr_rd_data
);

parameter IDLE   = 8'd0;
parameter WRITE  = 8'd1;
parameter READ   = 8'd2;
parameter FINISH = 8'd3;

reg  [7:0] state;
reg  [1:0] write_not_read;
reg  [7:0] address;
reg [31:0] data;

integer fh, status;

initial
begin
  fh = $fopen(CSR_FILE,"r");
end

function check_neof;
input dummy_input;
integer check_tmp;
integer status_tmp;
begin

  check_tmp = $fgetc(fh);

  if (check_tmp == -1) 
    check_neof = 1'b0;
  else
  begin
    check_neof = 1'b1; 
    status_tmp = $ungetc(check_tmp, fh);
  end
end
endfunction



always @(posedge clk or negedge reset_n) 
  if (!reset_n)
  begin
    state       <= IDLE;
    csr_write   <= 1'b0;
    csr_wr_data <= 32'd0;
    csr_read    <= 1'b0;
    csr_address <= 8'd0;
  end

  else 
  begin

    case(state)
  
      IDLE:
      begin
        if (1) //!check_neof(0)) //1)
        begin
          status = $fscanf(fh, "%x %x %x", write_not_read, address, data);
          csr_write <= 1'b0;
          csr_read  <= 1'b0;
          if (write_not_read == 2)
            state <= FINISH;
          else if (write_not_read == 1)
            state <= WRITE;
          else
            state <= READ;
        end
      end
      WRITE: 
      begin
        csr_write   <= 1'b1;
        csr_address <= address;
        csr_wr_data <= data;
        state  <= IDLE;
      end
      READ:
      begin
	csr_read   <= 1'b1;
        csr_address <= address;
        state  <= IDLE;
      end
      FINISH: 
        state  <= FINISH;
 

    endcase
  end

endmodule
