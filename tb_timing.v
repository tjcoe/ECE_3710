// Simple test bench used to make sure vgaTiming
// block is working perfectly. No display messages were
// used. Just looked at the waveforms and built some 
// counters into the code for testing.
module timingTest;

 reg clk, clr;
 wire hSync, vSync, bright;
 wire [9:0] hPos;
 wire [9:0] vPos;
 
 vgaTiming UUT (
   .clk(clk),
	.clr(clr),
	.hSync(hSync),
	.vSync(vSync),
	.bright(bright),
	.hPos(hPos),
	.vPos(vPos)
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
	 
  end
  
endmodule

  