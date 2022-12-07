// Simple top-level module tie together the 
// timing, bitGen, and thunderbird FSM circuits.
//
module vgaControl (
  input clk, clr,
  input [10:0] mX, 
  input [10:0] mY,
  //input [2:0] switches, This was used for the initial bitGen design
  output hSync = 1, vSync = 1, 
  output bright,
  output clk_25Mhz,       // drives pixel clock for VGA DAC
  output VGA_SYNC_N = 0,  // unused so tied to ground
  output [7:0] red,
  output [7:0] green,
  output [7:0] blue
  );
  
  // various wires for connecting inputs to outputs
  wire [9:0] hPos;
  wire [8:0] vPos;
  
  vgaTiming timing(clk,clr,hSync,vSync,bright,hPos,vPos,clk_25Mhz);
  bitGen paint(bright, hPos, vPos, mX, mY, red, green, blue); 
  

  
  endmodule