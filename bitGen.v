//
module bitGen (
  input bright,
  input [9:0] hPos,
  input [8:0] vPos,
  input [10:0] x,
  input [10:0] y,
  input [15:0] bufOut,
  output reg [7:0] red,
  output reg [7:0] green,
  output reg [7:0] blue,
  output [15:0] address
  );
  
  // Parameters for On/Off since 8-bit colors are all tied together on = 255 or 7'b1111_1111
  parameter [7:0] ON = 255;
  parameter [7:0] OFF= 0;
  
  // registers for drawing spaces
  reg box1; reg box2; reg box3; reg draw; reg mouse;
  
  reg [10:0] mX;
  reg [10:0] mY;
  wire [3:0] position;
  reg [3:0] bufPixel;
  
  // instantiates module to get pixel memory address and position based on current pixel location
  getPixel getPixel(hPos,yPos,position,address);

  // combinational always block
  always @*  
  begin
  
    case (position)
	   4'b0000: bufPixel = bufOut[3:0];
		4'b0001: bufPixel = bufOut[7:4];
		4'b0010: bufPixel = bufOut[11:8];
		4'b0100: bufPixel = bufOut[15:12];
		default: bufPixel = 0;
	 endcase
	 
	 mX = x;
	 mY = y;
  
	 // boundary deffinitions for color options and draw space
	 box1  = ((vPos <= 79) && (hPos <= 213));
	 box2  = ((vPos <= 79) && (hPos >= 214 && hPos <= 426));
	 box3  = ((vPos <= 79) && (hPos > 426));
	 draw  = (vPos >= 80);
	 // creates boundary for mouse image
	 mouse = ((hPos == mX    && (vPos >= mY  && vPos <= mY+16)) | 
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
	   red   = OFF;
	   green = OFF;
		blue  = OFF;
	 end	
	 else if (mouse) // draws mouse image
	 begin
	   red   = OFF;
		green = OFF;
		blue  = OFF;
	 end
	 else if (box1) // red box top left
	 begin
      red   = ON;
		green = OFF;
		blue  = OFF;
    end	
	 else if (box2) // green box top middle
	 begin
      red   = OFF;
		green = ON;
		blue  = OFF;
    end	
	 else if (box3) // blue box top right
	 begin
      red   = OFF;
		green = OFF;
		blue  = ON;
    end
	 else if (draw) // loads image buffer from memory
	 begin
	   red   = bufPixel[2];
		green = bufPixel[1];
		blue  = bufPixel[0];
	 end
	 else  // if the pixel is not in any of the boxes then paint the screen black
	 begin
	   red   = OFF;
		green = OFF;
		blue  = OFF;
    end	
  
  end
  
endmodule
  