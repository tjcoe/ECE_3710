module vgaControlTest;

reg clk, clr;
reg [15:0] bufOut;
reg [10:0] mX;
reg [10:0] mY;
wire VGA_SYNC_N = 0;
wire hSync, vSync, bright, clk_25Mhz;
wire [7:0] red, green, blue;
wire [15:0] address;

vgaControl UUT(
  clk, clr,
  mX, 
  mY,
  bufOut,
  hSync, vSync, 
  obright,
  clk_25Mhz,   // drives pixel clock for VGA DAC
  VGA_SYNC_N,  // unused so tied to ground
  red,
  green,
  blue,
  address
);
  
  
  
	// Generates the clock. 		
  initial begin
    clk = 0;
	 forever #1 clk = ~clk;
  end
  // holds clear low for a few clocks then lets the circuit run
  initial begin
    clr = 0;
	 #5 clr = 1;
	 bufOut = 16'b0000000000000000;
	 
	 #5
	 mX = 0;
	 mY = 80;
	 
	 #5
	 mX = 639;
	 mY = 479;
	 
	 #5
	 mX = 400;
	 mY = 400;
  end
  
endmodule

  