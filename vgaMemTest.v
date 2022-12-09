module vgaMemTest;

  reg clk, reset, start, hSync, vSync, bright, clk_25Mhz, VGA_SYNC_N;
  wire [7:0] red, green, blue;
  wire [2:0] btns;
  wire [41:0] hexDisplays;
  
CpuMem UUT(
  .clk(clk), .reset(reset), .start(start),
  .ps2_clk(0), .ps2_data(0),
  .hSync(hSync), .vSync(vSync), 
  .bright(bright),
  .clk_25Mhz(clk_25Mhz),       // drives pixel clock for VGA DAC
  .VGA_SYNC_N(VGA_SYNC_N),  // unused so tied to ground
  .red(red),
  .green(green),
  .blue(blue),
  .btns(btns), // 2 - lmb, 1 - mmb, 0 - rmb
  .hexDisplays(hexDisplays)
  );
  
  
  initial begin
    clk = 0;
	 forever #1 clk = ~clk;
  end
  
  initial begin
    #5
	 start = 1;
	 reset = 1;
	 
  end
  
endmodule
