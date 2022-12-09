module getPixelTest;

 reg [10:0] x = 0;
 reg [10:0] y = 80;
 wire [10:0] line;
 wire [3:0] position;
 wire [15:0] address;
 
 getPixel UUT (
   .x(x),
	.y(y),
	.position(position),
	.address(address)
	);
	
	 		
  initial begin
    #5
	 x = 639;
	 y = 80;
	 #5
	 x = 0;
	 y = 89;
	 #5
	 x = 639;
	 y = 479;
	 #5
	 x = 400;
	 y = 200;
	 #5;
	 x = 0;
	 y = 80;
	 #5;
	 x = 0;
	 y = 80;
	 #5;
	 x = 1;
	 y = 80;
	 #5;
	 x = 2;
	 y = 80;
	 #5;
	 x = 3;
	 y = 80;
	 #5;
	 x = 4;
	 y = 80;
	 #5;
	 x = 5;
	 y = 80;
	 #5;
	 x = 6;
	 y = 80;
	 #5;
	 x = 7;
	 y = 80;
	 #5;
	 x = 31;
	 y = 80;
	 #5;
	 x = 32;
	 y = 80;
	 #5;
  end
  
  
endmodule

  