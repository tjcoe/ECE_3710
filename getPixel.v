module getPixel (
  input [10:0] x,
  input [10:0] y,
  output reg [3:0] position,
  output reg [15:0] address
);

reg [10:0] xTemp;
reg [10:0] yTemp;
reg [10:0] line;

always @*
begin

  xTemp = x >> 5;
  yTemp = y - 80;
  yTemp = yTemp >> 3;
  
  yTemp = yTemp * 20;
  
  line = xTemp + yTemp;
  position = x % 4;
  
  address = (line * 16) + 16384;
  
end


endmodule
