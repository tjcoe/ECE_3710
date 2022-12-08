// This module controls the timing for the vga display
// and is the most important part. This module gets the correct
// timing for hSync, vSync, bright, hPos, and vPos.
// Also outputs the 25 Mhz pixel clock for the VGA DAC.
module vgaTiming (
  input clk, clr,
  output reg hSync = 1, vSync = 1, 
  output reg bright,
  output reg [9:0] hPos = 0,
  output reg [8:0] vPos = 0,
  output reg clkEnable
  );
  
  // Declare registers
  reg vBright      = 0;
  reg [9:0] hCount = 0;
  reg [9:0] vCount = 1;
  
  
  // This always block is the clock divider that drives the enable signal
  always @ (posedge clk)
  begin
    if (clkEnable == 1) clkEnable <= 0;   // We use 1 here because we need to divide the 50 Mhz clock by 2.
	 else clkEnable <= clkEnable+1;        // enable signal set high, since it only counts to 1.
  end
  
  // For my counts I started with the pulse -> back porch -> disp -> fp -> reset to pulse
  always @ (posedge clk, negedge clr)
  begin
    if (clr == 0)  // clear his the highest priority. Thus, checks clr signal first
    begin
      hCount <= 0;  // hCount is initialize to 0 because it will start the count at 1 after clear goes high.
	   vCount <= 1;  // vCount is initalized to 1 since I'm not using 0 base for the indexes.
    end
	 else if (clkEnable) // enable signal for the 25 MHz signal drives the circuit
	 begin
	   if (hCount == 800)  // checks to see if beam has reached the end of horizontal line
		begin
		  hCount <= 1;      // resets count back to 1
		  hSync  <= 0;      // begins the pulse for hSync
		  if (vCount == 521) // checks if vCount has hit the end of fp
	     begin
		    vCount <= 1;    // sets the line count back to 1
			 vSync  <= 0;    // enables vSync pulse
		  end
		  else
		  begin
		    if (vCount == 2) vSync     <= 1;   // disables the pulse once vCount gets to line 3
			 if (vCount == 31) vBright  <= 1;   // used to determine if we're in the vDisp zone
			 if (vCount == 511) vBright <= 0;   // 32-512 is the zone for vDisp
			 vCount <= vCount + 1;              // increments line count
		  end
		end
		else
		begin
		  if (hCount == 96) hSync <= 1;  // turns off the hSync pulse
		  hCount <= hCount + 1;          // increments hCount
		end
		  
		if (hCount < 784 && hCount > 143 && vBright)  // This statement is true when timing is in vDisp and hDisp regions
		begin
		  bright <= 1;                              // screen should be painting
		  vPos   <= vCount - 32;                    // converts the count into proper pixel positions
		  hPos   <= hCount - 144;                   // only enabled when screen is bright so pos is never out of screen range
		end
		else 
		begin
		  bright <= 0;      // screen should be dark (resetting beam)
		  vPos   <= 0;      // sets position to 0 when resetting beam so 
		  hPos   <= 0;      // position never exceeds 639/439 x/y
		end
	 end
  end	 
endmodule
