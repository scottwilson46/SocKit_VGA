// megafunction wizard: %Altera PLL v13.1%
// GENERATION: XML
// altera_pll_vga.v

// Generated using ACDS version 13.1 162 at 2014.03.23.15:19:33

`timescale 1 ps / 1 ps
module altera_pll_vga (
		input  wire  refclk,   //  refclk.clk
		input  wire  rst,      //   reset.reset
		output wire  outclk_0, // outclk0.clk
		output wire  locked    //  locked.export
	);

reg [31:0] count;

assign outclk_0 = refclk;
always @(posedge refclk or posedge rst)
  if (rst)
    count <= 'd0;
  else 
    count <= count + 'd1;

assign locked = count > 20;

endmodule
