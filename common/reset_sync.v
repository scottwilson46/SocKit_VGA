module reset_sync (

  input       clk,
  input       reset_n,

  output      reset_n_sync

);

reg reset_n_sync1;
reg reset_n_sync2;
reg reset_n_sync3;

always @(posedge clk or negedge reset_n)
  if (!reset_n)
  begin
  	reset_n_sync1 <= 1'b0;
  	reset_n_sync2 <= 1'b0;
  	reset_n_sync3 <= 1'b0;
  end
  else 
  begin
  	reset_n_sync1 <= reset_n;
  	reset_n_sync2 <= reset_n_sync1;
  	reset_n_sync3 <= reset_n_sync2;
  end

  assign reset_n_sync = reset_n_sync3;

endmodule
