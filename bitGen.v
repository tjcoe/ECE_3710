// bitGen module that controlls how the vga draws the screen
// Tom Coe
module bitGen (
  input clk,
  input bright,
  input [9:0] hPos,
  input [8:0] vPos,
  input [9:0] x,
  input [8:0] y,
  input [15:0] bufOut,
  output reg [7:0] red,
  output reg [7:0] green,
  output reg [7:0] blue,
  output reg [15:0] address
  );
  
  // Parameters for On/Off since 8-bit colors are all tied together on = 255 or 7'b1111_1111
  parameter [7:0] ON = 255;
  parameter [7:0] OFF= 0;
  
  // registers for drawing spaces
  reg box1; reg box2; reg box3; reg draw; reg mouse; reg mouseInside;
  
  reg [9:0] mX;
  reg [8:0] mY;
  reg [2:0] position;
  reg [3:0] bufPixel;
  reg [9:0] xTemp;
  reg [9:0] yTemp;
  reg [9:0] line;

  // combinational always block
  always @*  
  begin
    
	 mX = x;
	 mY = y;
  
	 // boundary deffinitions for color options and draw space
	 box1  = ((vPos <= 79) && (hPos <= 213));
	 box2  = ((vPos <= 79) && (hPos >= 214 && hPos <= 426));
	 box3  = ((vPos <= 79) && (hPos > 426));
	 draw  = (vPos >= 80);
	 // hard coded boundary for mouse image
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
				  
	 mouseInside = ((hPos == mX+1 && (vPos > mY && vPos <= mY+15)) |
	                (hPos == mX+2 && (vPos > mY+1 && vPos <= mY+14)) |
						 (hPos == mX+3 && (vPos > mY+2 && vPos <= mY+13)) |
						 (hPos == mX+4 && (vPos > mY+3 && vPos <= mY+12)) |
						 (hPos == mX+5 && (vPos > mY+4 && vPos <= mY+13)) |
						 (hPos == mX+6 && (vPos > mY+5 && vPos <= mY+15)) |
						 (hPos == mX+7 && (vPos > mY+6 && vPos <= mY+11)) |
						 (hPos == mX+7 && (vPos > mY+12 && vPos <= mY+17)) |
						 (hPos == mX+8 && (vPos > mY+13 && vPos <= mY+17)) |
						 (hPos == mX+8 && (vPos > mY+7 && vPos <= mY+11)) |
						 (hPos == mX+9 && (vPos > mY+8 && vPos <= mY+11)) |
						 (hPos == mX+10 && (vPos == mY+11)));
	 
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
	 else if (mouseInside) // draws mouse image
	 begin
	   red   = ON;
		green = ON;
		blue  = ON;
	 end
	 else if (draw) // loads image buffer from memory
	 begin
	   // The following math is used to optain proper pixel location in memory.
	   // The screen is divided into 8x8 pixel chunks in a 640x400 area.
	   // Thus there are 80 x 50 pixel chunks.
	   // Each line in memory holds 4 pixel values.
	   // Thus there are 20 lines of memory dedicated for each horizontal pixel line.
	   // 20 * 4 = 80 pixel chunks.
	   // So we take the x position and divid by 32 to get the line offset.
	   // i.e. xpos = 639 / 32 = 19 -> line offset is 19.
	   // For every y position we multiply by 20.
	   // i.e. ypos = 0-7 * 20 = 0. ypos = 8-15 = 1 * 20 = 20 -> line offset
	 
	   // divided xpos by 32 
      xTemp = hPos >> 5;
	   // subtracts 80 from ypos since draw space starts at 80
      yTemp = vPos - 80;
	   // divided ypos by 8
      yTemp = yTemp >> 3;
      yTemp = yTemp * 20;
	   // address offset in memory
      line = xTemp + yTemp;
      // multiply by 16 bits per line and add the offset to the starting address of 16384.
      address = (line * 16) + 16384;
	   // uses mod 4 to find the position of the pixel in the address line since there are four pixels per memory address.
	   position = (hPos / 8) % 4;
      // case statement to select specific pixel value
      case (position)
	     3'b000: bufPixel = bufOut[3:0];
		  3'b001: bufPixel = bufOut[7:4];
		  3'b010: bufPixel = bufOut[11:8];
		  3'b011: bufPixel = bufOut[15:12];
		  default: bufPixel = 0;
	   endcase
	   // case statement that tell which RGB to output based on memory info
	   case (bufPixel)
		  4'b0000: begin red = ON;  green = ON;  blue = ON;  end // white
		  4'b0001: begin red = ON;  green = OFF; blue = OFF; end // red
		  4'b0010: begin red = OFF; green = ON;  blue = OFF; end // green
		  4'b0100: begin red = OFF; green = OFF; blue = ON;  end // blue
		  default: begin red = OFF; green = OFF; blue = OFF; end // black
      endcase
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
	 else  // if the pixel is not in any of the boxes then paint the screen black
	 begin
	   red   = OFF;
		green = OFF;
		blue  = OFF;
    end	
  
  end
  
endmodule
  