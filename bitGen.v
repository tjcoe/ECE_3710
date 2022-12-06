//
module bitGen (
  input bright,
  input [9:0] hPos,
  input [8:0] vPos,
  input [9:0] mX,
  input [8:0] mY,
  output reg [7:0] red,
  output reg [7:0] green,
  output reg [7:0] blue
  );
  
  // Parameters for On/Off since 8-bit colors are all tied together on = 255 or 7'b1111_1111
  parameter [7:0] ON = 255;
  parameter [7:0] OFF= 0;
  
  // registers for drawing spaces
  reg box1; reg box2; reg box3; reg draw; reg mouse;
  
  // combinational always block
  always @*  
  begin
    
	 // boundary deffinitions for color options and draw space
	 box1  <= ((vPos <= 79) && (hPos <= 213));
	 box2  <= ((vPos <= 79) && (hPos >= 214 && hPos <= 426));
	 box3  <= ((vPos <= 79) && (hPos >= 426));
	 draw  <= (vPos >= 80);
	 // creates boundary for mouse image
	 mouse <= ((hPos == mX    && (vPos >= mY  && vPos <= mY+16)) | 
	           (hPos == mX+1  && (vPos == mY+1   | vPos == mY+16)) | 
				  (hPos == mX+2  && ( vPos == mY+2  | vPos == mY+15)) |
				  (hPos == mX+3  && ( vPos == mY+3  | vPos == mY+14)) |
				  (hPos == mX+4  && ( vPos == mY+4  | vPos == mY+13)) |
				  (hPos == mX+5  && ( vPos == mY+5  | vPos == mY+14 | vPos == mY+15)) | 
				  (hPos == mX+6  && ( vPos == mY+6  | vPos == mY+16 | vPos == mY+17)) |
				  (hPos == mX+7  && ( vPos == mY+7  | vPos == mY+12 | vPos == mY+13 | vPos == mY+18)) |
				  (hPos == mX+8  && ( vPos == mY+8  | vPos == mY+12 | vPos == mY+14 | vPos == mY+15 | vPos == mY+18)) |
				  (hPos == mX+9  && ( vPos == mY+9  | vPos == mY+12 | vPos == mY+16 | vPos == mY+17)) |
				  (hPos == mX+10 && ( vPos == mY+10 | vPos == mY+12)) |
				  (hPos == mX+11 && ( vPos == mY+11 | vPos == mY+11 | vPos == mY+12)));
	 
	 // Draws the screen
    if (~bright) // if bright is low don't paint rbg = 0
	 begin
	   red   <= OFF;
	   green <= OFF;
		blue  <= OFF;
	 end
	 else if (box1) // red box top left
	 begin
      red   <= ON;
		green <= OFF;
		blue  <= OFF;
    end	
	 else if (box2) // green box top middle
	 begin
      red   <= OFF;
		green <= ON;
		blue  <= OFF;
    end	
	 else if (box3) // blue box top right
	 begin
      red   <= OFF;
		green <= OFF;
		blue  <= ON;
    end	
	 else if (mouse) // draws mouse image
	 begin
	   red   <= OFF;
		green <= OFF;
		blue  <= OFF;
	 end
	 else if (draw) // loads image buffer from memory (not done just white right now)
	 begin
	   red   <= ON;
		green <= ON;
		blue  <= ON;
	 end
	 else  // if the pixel is not in any of the boxes then paint the screen black
	 begin
	   red   <= OFF;
		green <= OFF;
		blue  <= OFF;
    end	
  
  end
  
endmodule
  