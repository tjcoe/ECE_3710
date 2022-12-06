module bitGenTest;

 reg clk, clr;
 wire hSync, vSync, bright;
 wire [9:0] hPos;
 wire [8:0] vPos;
 wire [7:0] red;
 wire [7:0] green;
 wire [7:0] blue;
 
 vgaControl UUT (
   .clk(clk),
	.clr(clr),
	.hSync(hSync),
	.vSync(vSync),
	.bright(bright),
	.hPos(hPos),
	.vPos(vPos),
	.red(red),
	.green(green),
	.blue(blue)
	);
	
	// Generates the clock. 		
  initial begin
    clk = 0;
	 forever #1 clk = ~clk;
  end
  
  initial begin
    clr = 0;
	 #5 clr = 1;
	 
  end
  
endmodule

  