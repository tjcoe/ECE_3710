// Top level module. Instantiates block ram,
// io block, cpu, vga controller, and mouse controller.
// Also has output to 7-seg for mouse debug.
module CpuMem(
  input clk, reset, start,
  inout ps2_clk, ps2_data,
  output hSync, vSync, 
  output bright,
  output clk_25Mhz,   // drives pixel clock for VGA DAC
  output VGA_SYNC_N,  // unused so tied to ground
  output [7:0] red,
  output [7:0] green,
  output [7:0] blue,
  output [2:0] btns, // 2 - lmb, 1 - mmb, 0 - rmb
  output [41:0] hexDisplays // displays current mouse x and y
  );
  
    // wire / register declarations
    wire [15:0] memDataA, addrA, writeDataA, memDataB, addrB, WriteDataB;
    wire we;
	 wire weB = 0;
	 wire [15:0] bufOut;
	 wire [15:0] pixelAddress;
	 wire [15:0] memDataAram;
	 wire [15:0] memDataAio;
	 wire [15:0] memDataBram;
	 wire [15:0] memDataBio;
	 wire [3:0] x1s, x10s, x100s;
	 wire [3:0] y1s, y10s, y100s;
	 wire [15:0] xPos, yPos;
	 
	 // mux to decide if address is in memory or io space
	 assign memDataA = addrA[15:14] == 2'b11 ? memDataAio : memDataAram;
    
	 
	 // cpu instantiation
    cpu proc(.clk(clk), .reset(reset), .memDataInbound(memDataA),
             .memWrite(we), .memWriteData(writeDataA), .outAddr(addrA));
	
    // block ram instantiation	
    ram_block mem(
		.a_address(addrA[15:4]), 
		.b_address(addrB[15:4]), 
		.a_writeData(writeDataA), 
		.b_writeData(WriteDataB), 
		.a_we(we), 
		.b_we(weB), 
		.clk(clk),
      .a_out(memDataAram), 
		.b_out(memDataBram)
		);
	 
    // vga instantiation	 
	 vgaControl draw(clk,reset,xPos,yPos,memDataBram,hSync,vSync,bright,clk_25Mhz,VGA_SYNC_N,red,green,blue,addrB);
    
	 // io block instantiation
	 io_block io_block(
		.a_address(addrA[15:4]), 
		.b_address(0), 
		.a_writeData(writeDataA), 
		.b_writeData(WriteDataB), 
		.a_we(we), 
		.b_we(weB), 
		.clk(clk),
		.lmb(btns[2]),
		.mmb(btns[1]),
		.rmb(btns[0]),
		.mouse_x(xPos),
		.mouse_y(yPos),
		.a_out(memDataAio), 
		.b_out(memDataBio)
		);
	 // mouse controller instantiation
	 ps2_mouse #(
			.WIDTH(640),
			.HEIGHT(480),
			.BIN(5),
			.HYSTERESIS(3)
			) 
			mouse(
			.start(~start),  
			.reset(~reset),  
			.CLOCK_50(clk),  
			.PS2_CLK(ps2_clk), 
			.PS2_DAT(ps2_data), 
			.button_left(btns[2]),  
			.button_right(btns[0]),  
			.button_middle(btns[1]),  
			.bin_x(xPos),
			.bin_y(yPos)
			);

	// 7-seg display mouse coordinates
	assign x1s = xPos % 10;
	assign x10s = (xPos / 10) % 10;
	assign x100s = (xPos / 100) % 10;
	
	assign y1s = yPos % 10;
	assign y10s = (yPos / 10) % 10;
	assign y100s = (yPos / 100) % 10;

	sev_seg sev_x1s (.value(x1s), .display(hexDisplays[6:0]));
	sev_seg sev_x10s (.value(x10s), .display(hexDisplays[13:7]));
	sev_seg sev_x100s (.value(x100s), .display(hexDisplays[20:14]));
	
	sev_seg sev_y1s (.value(y1s), .display(hexDisplays[27:21]));
	sev_seg sev_y10s (.value(y10s), .display(hexDisplays[34:28]));
	sev_seg sev_y100s (.value(y100s), .display(hexDisplays[41:35]));
	
endmodule

// simple module for 7-seg display
module sev_seg(input [3:0] value, output reg [6:0] display);
	
	always@* 
	begin
		case(value)
			4'b0000 : display = ~7'b0111111; // 0
			4'b0001 : display = ~7'b0000110; // 1
			4'b0010 : display = ~7'b1011011; // 2
			4'b0011 : display = ~7'b1001111; // 3
			4'b0100 : display = ~7'b1100110; // 4
			4'b0101 : display = ~7'b1101101; // 5
			4'b0110 : display = ~7'b1111101; // 6
			4'b0111 : display = ~7'b0000111; // 7
			4'b1000 : display = ~7'b1111111; // 8
			4'b1001 : display = ~7'b1100111; // 9
			4'b1010 : display = ~7'b1110111; // A
			4'b1011 : display = ~7'b1111100; // b
			4'b1100 : display = ~7'b1011000; // c
			4'b1101 : display = ~7'b1011110; // d
			4'b1110 : display = ~7'b1111001; // E
			4'b1111 : display = ~7'b1110001; // F
			default : display = ~7'b0000000;
		endcase
	end
endmodule
