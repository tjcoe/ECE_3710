// Simple top-level module tie together the 
// timing, bitGen, and thunderbird FSM circuits.
//
module vgaControl (
  input clk, clr,
  input [10:0] mX, 
  input [10:0] mY,
  input [15:0] bufOut,
  output hSync, vSync, 
  output bright,
  output clk_25Mhz,       // drives pixel clock for VGA DAC
  output VGA_SYNC_N,  // unused so tied to ground
  output [7:0] red,
  output [7:0] green,
  output [7:0] blue,
  output [15:0] address
  );
  
  // various wires for connecting inputs to outputs
  wire [9:0] hPos;
  wire [8:0] vPos;
  
  vgaTiming timing(clk,clr,hSync,vSync,bright,hPos,vPos,clk_25Mhz);
  bitGen paint(bright, hPos, vPos, mX, mY, bufOut, red, green, blue,address); 
  

  
  endmodule
