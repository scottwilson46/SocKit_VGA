module async_handshake (

	  input req_clk,
	  input ack_clk,
	  input req_reset_n,
	  input ack_reset_n,

	  input req_in,

	  output ack_out

);

wire next_req_to;
reg req_to;
reg ack_reg1;
reg ack_reg2;
reg ack_reg3;
wire next_ack_from;
reg ack_from;
reg req_reg1;
reg req_reg2;
reg req_reg3;
reg req_in_reg;

assign ack_out = req_reg2 & ~req_reg3;

assign next_req_to = req_in & ~req_in_reg ? 1'b1 :
                     (ack_reg2 & ~ack_reg3) ? 1'b0 :
                     req_to;

always @(posedge req_clk or negedge req_reset_n)
  if (!req_reset_n)
  begin
  	req_to     <= 1'b0;
  	req_in_reg <= 1'b0;
  	ack_reg1   <= 1'b0;
  	ack_reg2   <= 1'b0;
    ack_reg3   <= 1'b0;
  end
  else begin
  	req_to     <= next_req_to;
  	req_in_reg <= req_in;
  	ack_reg1   <= ack_from;
  	ack_reg2   <= ack_reg1;
  	ack_reg3   <= ack_reg2;
  end

assign next_ack_from = (req_reg2 & ~req_reg3) ? 1'b1 :
                       (~req_reg2 & req_reg3) ? 1'b0 :
                       ack_from;

always @(posedge ack_clk or negedge ack_reset_n)
  if (!ack_reset_n)
  begin
  	ack_from  <= 1'b0;
  	req_reg1  <= 1'b0;
  	req_reg2  <= 1'b0;
  	req_reg3  <= 1'b0;
  end
  else begin
  	ack_from  <= next_ack_from;
  	req_reg1  <= req_to;
  	req_reg2  <= req_reg1;
  	req_reg3  <= req_reg2;
  end

endmodule