//module ECE_3710
//	(
//		input clk, reset, advance,
//		output reg [9:0] leds,
//		output reg [13:0] left_7_seg_pair, right_7_seg_pair
//	);
//
//
//	reg [11:0] a_add = 12'h400;
//	reg [11:0] b_add = 12'h800;
//	
//	reg a_we = 0, b_we = 0;
//	
//	reg [15:0] a_write = 0, b_write = 0;
//	wire [15:0] a_data, b_data;
//	
//	ram_block ram (.a_address(a_add), .b_address(b_add), .a_writeData(a_write), .b_writeData(b_write), .a_we(a_we), .b_we(b_we), .clk(clk), .a_out(a_data), .b_out(b_data));
//	
//	
//	reg canAdvance = 0;
//	reg [1:0] CURRENT_STATE = 0;
//	
//	
//	always@(posedge clk) 
//	begin
//		if (!reset)
//		begin
//			a_add <= 12'h400;
//			b_add <= 12'h800;
//			a_we <= 0;
//			b_we <= 0;
//			a_write <= 0;
//			b_write <= 0;
//			CURRENT_STATE <= 0;
//		end
//		
//		if(!advance && canAdvance)
//		begin
//			canAdvance <= 0;
//			
//			case(CURRENT_STATE)
//				2'b00: 
//				begin
//					CURRENT_STATE <= 2'b01;
//					a_add <= 12'h401;
//					a_we <= 1;
//					a_write <= 16'h002F;
//				end
//				2'b01:
//				begin
//					CURRENT_STATE <= 2'b10;
//					a_add <= 12'h402;
//					a_we <= 1;
//					a_write <= 16'h0071;
//				end
//				2'b10:
//				begin
//					CURRENT_STATE <= 2'b11;
//					a_add <= 12'h401;
//					a_we <= 0;				
//				end
//				2'b11:
//				begin
//					CURRENT_STATE <= 2'b00;
//					a_add <= 12'h402;
//					a_we <= 0;
//					
//				end
//				default: CURRENT_STATE <= 2'b00;
//			endcase
//			
//		end
//		else if(advance && !canAdvance) 
//		begin
//			canAdvance <= 1;
//		end
//	end
//	
//	
//	
//	always @*
//	begin
//	 	leds = a_add[9:0];
//    	// Note that the 7-segment displays on the DE1-SoC board are
//    	// "active low" - a 0 turns on the segment, and 1 turns it off
//    	case(a_data[3:0])
//    	  	4'b0000 : left_7_seg_pair[6:0] = ~7'b0111111; // 0
//    	  	4'b0001 : left_7_seg_pair[6:0] = ~7'b0000110; // 1
//    	  	4'b0010 : left_7_seg_pair[6:0] = ~7'b1011011; // 2
//    	  	4'b0011 : left_7_seg_pair[6:0] = ~7'b1001111; // 3
//    	  	4'b0100 : left_7_seg_pair[6:0] = ~7'b1100110; // 4
//    	  	4'b0101 : left_7_seg_pair[6:0] = ~7'b1101101; // 5
//    	  	4'b0110 : left_7_seg_pair[6:0] = ~7'b1111101; // 6
//    	  	4'b0111 : left_7_seg_pair[6:0] = ~7'b0000111; // 7
//    	  	4'b1000 : left_7_seg_pair[6:0] = ~7'b1111111; // 8
//    	  	4'b1001 : left_7_seg_pair[6:0] = ~7'b1100111; // 9 
//    	  	4'b1010 : left_7_seg_pair[6:0] = ~7'b1110111; // A
//    	  	4'b1011 : left_7_seg_pair[6:0] = ~7'b1111100; // b
//    	  	4'b1100 : left_7_seg_pair[6:0] = ~7'b1011000; // c
//    	  	4'b1101 : left_7_seg_pair[6:0] = ~7'b1011110; // d
//    	  	4'b1110 : left_7_seg_pair[6:0] = ~7'b1111001; // E
//    	  	4'b1111 : left_7_seg_pair[6:0] = ~7'b1110001; // F
//    	  	default : left_7_seg_pair[6:0] = ~7'b0000000; // Always good to have a default! 
//    	endcase
//
//	 	case(a_data[7:4])
//    	  	4'b0000 : left_7_seg_pair[13:7] = ~7'b0111111; // 0
//    	  	4'b0001 : left_7_seg_pair[13:7] = ~7'b0000110; // 1
//    	  	4'b0010 : left_7_seg_pair[13:7] = ~7'b1011011; // 2
//    	  	4'b0011 : left_7_seg_pair[13:7] = ~7'b1001111; // 3
//    	  	4'b0100 : left_7_seg_pair[13:7] = ~7'b1100110; // 4
//    	  	4'b0101 : left_7_seg_pair[13:7] = ~7'b1101101; // 5
//    	  	4'b0110 : left_7_seg_pair[13:7] = ~7'b1111101; // 6
//    	  	4'b0111 : left_7_seg_pair[13:7] = ~7'b0000111; // 7
//    	  	4'b1000 : left_7_seg_pair[13:7] = ~7'b1111111; // 8
//    	  	4'b1001 : left_7_seg_pair[13:7] = ~7'b1100111; // 9 
//    	  	4'b1010 : left_7_seg_pair[13:7] = ~7'b1110111; // A
//    	  	4'b1011 : left_7_seg_pair[13:7] = ~7'b1111100; // b
//    	  	4'b1100 : left_7_seg_pair[13:7] = ~7'b1011000; // c
//    	  	4'b1101 : left_7_seg_pair[13:7] = ~7'b1011110; // d
//    	  	4'b1110 : left_7_seg_pair[13:7] = ~7'b1111001; // E
//    	  	4'b1111 : left_7_seg_pair[13:7] = ~7'b1110001; // F
//    	  	default : left_7_seg_pair[13:7] = ~7'b0000000; // Always good to have a default! 
//    	endcase
//
//		case(a_write[3:0])
//    	  	4'b0000 : right_7_seg_pair[6:0] = ~7'b0111111; // 0
//    	  	4'b0001 : right_7_seg_pair[6:0] = ~7'b0000110; // 1
//    	  	4'b0010 : right_7_seg_pair[6:0] = ~7'b1011011; // 2
//    	  	4'b0011 : right_7_seg_pair[6:0] = ~7'b1001111; // 3
//    	  	4'b0100 : right_7_seg_pair[6:0] = ~7'b1100110; // 4
//    	  	4'b0101 : right_7_seg_pair[6:0] = ~7'b1101101; // 5
//    	  	4'b0110 : right_7_seg_pair[6:0] = ~7'b1111101; // 6
//    	  	4'b0111 : right_7_seg_pair[6:0] = ~7'b0000111; // 7
//    	  	4'b1000 : right_7_seg_pair[6:0] = ~7'b1111111; // 8
//    	  	4'b1001 : right_7_seg_pair[6:0] = ~7'b1100111; // 9 
//    	  	4'b1010 : right_7_seg_pair[6:0] = ~7'b1110111; // A
//    	  	4'b1011 : right_7_seg_pair[6:0] = ~7'b1111100; // b
//    	  	4'b1100 : right_7_seg_pair[6:0] = ~7'b1011000; // c
//    	  	4'b1101 : right_7_seg_pair[6:0] = ~7'b1011110; // d
//    	  	4'b1110 : right_7_seg_pair[6:0] = ~7'b1111001; // E
//    	  	4'b1111 : right_7_seg_pair[6:0] = ~7'b1110001; // F
//    	  	default : right_7_seg_pair[6:0] = ~7'b0000000; // Always good to have a default! 
//    	endcase
//
//		case(a_write[7:4])
//    	  	4'b0000 : right_7_seg_pair[13:7] = ~7'b0111111; // 0
//    	  	4'b0001 : right_7_seg_pair[13:7] = ~7'b0000110; // 1
//    	  	4'b0010 : right_7_seg_pair[13:7] = ~7'b1011011; // 2
//    	  	4'b0011 : right_7_seg_pair[13:7] = ~7'b1001111; // 3
//    	  	4'b0100 : right_7_seg_pair[13:7] = ~7'b1100110; // 4
//    	  	4'b0101 : right_7_seg_pair[13:7] = ~7'b1101101; // 5
//    	  	4'b0110 : right_7_seg_pair[13:7] = ~7'b1111101; // 6
//    	  	4'b0111 : right_7_seg_pair[13:7] = ~7'b0000111; // 7
//    	  	4'b1000 : right_7_seg_pair[13:7] = ~7'b1111111; // 8
//    	  	4'b1001 : right_7_seg_pair[13:7] = ~7'b1100111; // 9 
//    	  	4'b1010 : right_7_seg_pair[13:7] = ~7'b1110111; // A
//    	  	4'b1011 : right_7_seg_pair[13:7] = ~7'b1111100; // b
//    	  	4'b1100 : right_7_seg_pair[13:7] = ~7'b1011000; // c
//    	  	4'b1101 : right_7_seg_pair[13:7] = ~7'b1011110; // d
//    	  	4'b1110 : right_7_seg_pair[13:7] = ~7'b1111001; // E
//    	  	4'b1111 : right_7_seg_pair[13:7] = ~7'b1110001; // F
//    	  	default : right_7_seg_pair[13:7] = ~7'b0000000; // Always good to have a default! 
//    	endcase
//	end
//
//endmodule

module ECE_3710
	(
		input clk, start, clr, vgaClr,
		inout ps2_clk, ps2_data,
		output [2:0] btns, // 2 - lmb, 1 - mmb, 0 - rmb
		output [41:0] hexDisplays,
		output hSync = 1, vSync = 1, 
      output bright,
      output clk_25Mhz,       // drives pixel clock for VGA DAC
      output VGA_SYNC_N = 0,  // unused so tied to ground
      output [7:0] red,
      output [7:0] green,
      output [7:0] blue
	);
	
	
	wire [3:0] x1s, x10s, x100s;
	wire [3:0] y1s, y10s, y100s;
	
	wire [10:0] xPos, yPos;
	
	ps2_mouse #(
			.WIDTH(640),
			.HEIGHT(480),
			.BIN(5),
			.HYSTERESIS(3)
			) 
			mouse(
			.start(~start),  
			.reset(~clr),  
			.CLOCK_50(clk),  
			.PS2_CLK(ps2_clk), 
			.PS2_DAT(ps2_data), 
			.button_left(btns[2]),  
			.button_right(btns[0]),  
			.button_middle(btns[1]),  
			.bin_x(xPos),
			.bin_y(yPos)
			);
			
	// instantiate vga controller
   vgaControl draw(clk, vgaClr, xPos, yPos, hSync, vSync, bright, clk_25Mhz, VGA_SYNC_N, red, green, blue);
	
		
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
			default : display = ~7'b0000000; // Always good to have a default! 
		endcase
	end
	
endmodule

