//
//module io_block #(parameter DATA_SIZE = 16, parameter ADDRESS_SIZE = 12)
//	(
//		input [(ADDRESS_SIZE - 1) : 0] a_address, b_address,
//		input [(DATA_SIZE - 1) : 0] 	 a_writeData, b_writeData,
//		input a_we, b_we, clk,
//		input [9:0] switches,
//		input [3:0] pushButtons,
//		input lmb, mmb, rmb,
//		input [15:0] mouse_x, mouse_y,
//		output reg [(DATA_SIZE - 1) : 0] a_out, b_out
//	);
//
//	reg [9:0] leds;
//	reg [(7*2 - 1):0] dualHexSegment[2:0];
//
////	io_block_impl #(.DATA_SIZE(16), ADDRESS_SIZE(12))
////	io_block_a
////	(
////		.address(a_address),
////		.writeData(a_writeData),
////		.we(a_we),
////		.clk(clk),
////		.switches(switches),
////		.pushButtons(pushButtons),
////		.lmb(lmb),
////		.mmb(mmb),
////		.rmb(rmb),
////		.mouse_x(mouse_x),
////		.mouse_y(mouse_y),
////		.leds(leds),
////		.dualHexSegment(dualHexSegment),
////		.out(a_out)
////	);
//	
//	
////	io_block_impl #(.DATA_SIZE(16), ADDRESS_SIZE(12))
////	io_block_b
////	(
////		.address(b_address),
////		.writeData(b_writeData),
////		.we(b_we),
////		.clk(clk),
////		.switches(switches),
////		.pushButtons(pushButtons),
////		.lmb(lmb),
////		.mmb(mmb),
////		.rmb(rmb),
////		.mouse_x(mouse_x),
////		.mouse_y(mouse_y),
////		.leds(leds),
////		.dualHexSegment(dualHexSegment),
////		.out(b_out)
////	);
//	
//	
//	
////	wire [ADDRESS_SIZE + 4:0] a_fullAddress = { a_address, 4'b0000 };
////	wire [ADDRESS_SIZE + 4:0] b_fullAddress = { b_address, 4'b0000 };
////	
////	always@(posedge clk)
////	begin
////		if(a_address[ADDRESS_SIZE-1:ADDRESS_SIZE-2] == 2'b11)
////		begin
////			case (a_address)
////				12'hFFF: // LEDS
////				begin
////					if (a_we)
////					begin
////						leds <= a_writeData[9:0];
////					end
////					a_out <= 0;
////				end
////
////				12'hFFE: // Switches
////					a_out <= { 6'b000000, switches };
////				
////
////				12'hFFD, 12'hFFC, 12'hFFB: // Right Dual Hex Display 13:7 left hex, 6:0 right hex
////				begin
////					if (a_we)
////					begin
////						dualHexSegment[a_address[1:0]] <= a_writeData[6:0];
////					end
////					a_out <= 0;
////				end
////
////				default: a_out <= 0;
////				
////				12'hFFA:
////					a_out <= { 12'b000000000000, pushButtons };
////					
////				12'hFF9:
////					a_out <= { 13'b0000000000000, lmb, mmb, rmb };
////					
////				12'hFF8:
////					a_out <= mouse_x;
////				
////				12'hFF7:
////					a_out <= mouse_y;
////				
////			endcase
////		end
////	end
//endmodule
//
//module io_block_impl #(parameter DATA_SIZE = 16, parameter ADDRESS_SIZE = 12)
//	(
//		input [(ADDRESS_SIZE - 1) : 0] address,
//		input [(DATA_SIZE - 1) : 0] 	 writeData,
//		input we, clk,
//		input [9:0] switches,
//		input [3:0] pushButtons,
//		input lmb, mmb, rmb,
//		input [15:0] mouse_x, mouse_y,
//		inout [9:0] leds,
//		inout [(7*2 - 1):0] dualHexSegment[2:0],
//		output reg [(DATA_SIZE - 1) : 0] out
//	);
//	
//	wire [ADDRESS_SIZE + 4:0] fullAddress = { address, 4'b0000 };
//	
//	always@(posedge clk)
//	begin
//		if(address[ADDRESS_SIZE-1:ADDRESS_SIZE-2] == 2'b11)
//		begin
//			case (address)
//				12'hFFF: // LEDS
//				begin
//					if (we)
//					begin
//						leds <= writeData[9:0];

module io_block #(parameter DATA_SIZE = 16, parameter ADDRESS_SIZE = 12)
	(
		input [(ADDRESS_SIZE - 1) : 0] a_address, b_address,
		input [(DATA_SIZE - 1) : 0] 	 a_writeData, b_writeData,
		input a_we, b_we, clk,
		input [9:0] switches,
		input [3:0] pushButtons,
		input lmb, mmb, rmb,
		input [15:0] mouse_x, mouse_y,
		output reg [(DATA_SIZE - 1) : 0] a_out, b_out
	);

	reg [9:0] leds;
	reg [(7*2 - 1):0] dualHexSegment[2:0];

	io_block_impl #(.DATA_SIZE(16), ADDRESS_SIZE(12))
	io_block_a
	(
		.address(a_address),
		.writeData(a_writeData),
		.we(a_we),
		.clk(clk),
		.switches(switches),
		.pushButtons(pushButtons),
		.lmb(lmb),
		.mmb(mmb),
		.rmb(rmb),
		.mouse_x(mouse_x),
		.mouse_y(mouse_y),
		.leds(leds),
		.dualHexSegment(dualHexSegment),
		.out(a_out)
	);
	
	
	io_block_impl #(.DATA_SIZE(16), ADDRESS_SIZE(12))
	io_block_b
	(
		.address(b_address),
		.writeData(b_writeData),
		.we(b_we),
		.clk(clk),
		.switches(switches),
		.pushButtons(pushButtons),
		.lmb(lmb),
		.mmb(mmb),
		.rmb(rmb),
		.mouse_x(mouse_x),
		.mouse_y(mouse_y),
		.leds(leds),
		.dualHexSegment(dualHexSegment),
		.out(b_out)
	);
	
	
	
//	wire [ADDRESS_SIZE + 4:0] a_fullAddress = { a_address, 4'b0000 };
//	wire [ADDRESS_SIZE + 4:0] b_fullAddress = { b_address, 4'b0000 };
//	
//	always@(posedge clk)
//	begin
//		if(a_address[ADDRESS_SIZE-1:ADDRESS_SIZE-2] == 2'b11)
//		begin
//			case (a_address)
//				12'hFFF: // LEDS
//				begin
//					if (a_we)
//					begin
//						leds <= a_writeData[9:0];
//					end
//					a_out <= 0;
//				end
//
//				12'hFFE: // Switches
//					a_out <= { 6'b000000, switches };
//				
//
//				12'hFFD, 12'hFFC, 12'hFFB: // Right Dual Hex Display 13:7 left hex, 6:0 right hex
//				begin
//					if (we)
//					begin
//						dualHexSegment[address[1:0]] <= writeData[6:0];
//					end
//					a_out <= 0;
//				end
//				
//				12'hFFA:
//					out <= { 12'b000000000000, pushButtons };
//					
//				12'hFF9:
//					out <= { 13'b0000000000000, lmb, mmb, rmb };
//					
//				12'hFF8:
//					out <= mouse_x;
//				
//				12'hFF7:
//					out <= mouse_y;
//				
//				
//				default: a_out <= 0;
//					if (a_we)
//					begin
//						dualHexSegment[a_address[1:0]] <= a_writeData[6:0];
//					end
//					a_out <= 0;
//				end
//
//				default: a_out <= 0;
//				
//				12'hFFA:
//					a_out <= { 12'b000000000000, pushButtons };
//					
//				12'hFF9:
//					a_out <= { 13'b0000000000000, lmb, mmb, rmb };
//					
//				12'hFF8:
//					a_out <= mouse_x;
//				
//				12'hFF7:
//					a_out <= mouse_y;
//				
//			endcase
//		end
//	end
//endmodule
//	
//
//
//module ram_block #(parameter DATA_SIZE = 16, parameter ADDRESS_SIZE = 12)
//	(
//		input [(ADDRESS_SIZE - 1) : 0] a_address, b_address,
//		input [(DATA_SIZE - 1) : 0] 	 a_writeData, b_writeData,
//		input a_we, b_we, clk,
//		output reg [(DATA_SIZE - 1) : 0] a_out, b_out
//	);
//	
//	
//	reg [(DATA_SIZE - 1) : 0] memory[(2** ADDRESS_SIZE - 1) : 0];
//	
//	initial 
//	begin
////		$readmemb("C:\\Users\\Isaac\\Documents\\ECE3710\\project\\ECE_3710\\cr16Code.dat", memory);
//	end
//
//	/*	FFFF(11)	_____________
//	*				|				|
//	*				|				|
//	*				|	  IO		|
//	*				|				|
//	*				|				|
//	*	C000(11)	|-----------|
//	*				|				|
//	*				|				|
//	*				|	 Memory	|
//	*				|				|
//	*				|				|
//	*	8000(10)	|				|
//	*				|				|
//	*				|				|
//	*				|	 Memory	|
//	*				|				|
//	*				|				|
//	*	4000(01)	|-----------|
//	*				|				|
//	*				|				|
//	*				|	 Code		|
//	*				|				|
//	*	0000(00)	|___________|
//	*/
//	always @ (posedge clk)
//	begin
//		// 00 -> Even if we don't write
//		// 10 01 -> Read and writes like normal
//		// 11 -> Do nothing
//
//		case (a_address[ADDRESS_SIZE-1:ADDRESS_SIZE-2])
//			2'b00: a_out <= memory[a_address]; // Do not allow writes to code section
//			2'b01, 2'b10:
//			begin
//				if (a_we)
//				begin
//					memory[a_address] <= a_writeData;
//					a_out <= a_writeData;
//				end
//				else a_out <= memory[a_address];
//			end
//			// 11: // Do nothing, IO Space
//			default: ;
//		endcase
//
//		case (b_address[ADDRESS_SIZE-1:ADDRESS_SIZE-2])
//			2'b00: b_out <= memory[b_address]; // Do not allow writes to code section
//			2'b01, 2'b10:
//			begin
//				if (b_we)
//				begin
//					memory[b_address] <= b_writeData;
//					b_out <= b_writeData;
//				end
//				else b_out <= memory[b_address];
//			end
//			// 11: // Do nothing, IO Space
//			default: ;
//		endcase
//	end
//endmodule
endmodule

module io_block_impl #(parameter DATA_SIZE = 16, parameter ADDRESS_SIZE = 12)
	(
		input [(ADDRESS_SIZE - 1) : 0] address,
		input [(DATA_SIZE - 1) : 0] 	 writeData,
		input we, clk,
		input [9:0] switches,
		input [3:0] pushButtons,
		input lmb, mmb, rmb,
		input [15:0] mouse_x, mouse_y,
		inout [9:0] leds,
		inout [(7*2 - 1):0] dualHexSegment[2:0],
		output reg [(DATA_SIZE - 1) : 0] out
	);
	
	wire [ADDRESS_SIZE + 4:0] fullAddress = { address, 4'b0000 };
	
	always@(posedge clk)
	begin
		if(address[ADDRESS_SIZE-1:ADDRESS_SIZE-2] == 2'b11)
		begin
			case (address)
				12'hFFF: // LEDS
				begin
					if (we)
					begin
						leds <= writeData[9:0];
					end
					a_out <= 0;
				end

				12'hFFE: // Switches
					a_out <= { 6'b000000, switches };
				

				12'hFFD, 12'hFFC, 12'hFFB: // Right Dual Hex Display 13:7 left hex, 6:0 right hex
				begin
					if (we)
					begin
						dualHexSegment[address[1:0]] <= writeData[6:0];
					end
					a_out <= 0;
				end
				
				12'hFFA:
					out <= { 12'b000000000000, pushButtons };
					
				12'hFF9:
					out <= { 13'b0000000000000, lmb, mmb, rmb };
					
				12'hFF8:
					out <= mouse_x;
				
				12'hFF7:
					out <= mouse_y;
				
				
				default: a_out <= 0;
				
			endcase
		end
	end
endmodule
	


module ram_block #(parameter DATA_SIZE = 16, parameter ADDRESS_SIZE = 12)
	(
		input [(ADDRESS_SIZE - 1) : 0] a_address, b_address,
		input [(DATA_SIZE - 1) : 0] 	 a_writeData, b_writeData,
		input a_we, b_we, clk,
		output reg [(DATA_SIZE - 1) : 0] a_out, b_out
	);
	
	
	reg [(DATA_SIZE - 1) : 0] memory[(2** ADDRESS_SIZE - 1) : 0];
	
	initial 
	begin
//		$readmemb("C:\\Users\\Isaac\\Documents\\ECE3710\\project\\ECE_3710\\cr16Code.dat", memory);
	end

	/*	FFFF(11)	_____________
	*				|				|
	*				|				|
	*				|	  IO		|
	*				|				|
	*				|				|
	*	C000(11)	|-----------|
	*				|				|
	*				|				|
	*				|	 Memory	|
	*				|				|
	*				|				|
	*	8000(10)	|				|
	*				|				|
	*				|				|
	*				|	 Memory	|
	*				|				|
	*				|				|
	*	4000(01)	|-----------|
	*				|				|
	*				|				|
	*				|	 Code		|
	*				|				|
	*	0000(00)	|___________|
	*/
	always @ (posedge clk)
	begin
		// 00 -> Even if we don't write
		// 10 01 -> Read and writes like normal
		// 11 -> Do nothing

		case (a_address[ADDRESS_SIZE-1:ADDRESS_SIZE-2])
			2'b00: a_out <= memory[a_address]; // Do not allow writes to code section
			2'b01, 2'b10:
			begin
				if (a_we)
				begin
					memory[a_address] <= a_writeData;
					a_out <= a_writeData;
				end
				else a_out <= memory[a_address];
			end
			// 11: // Do nothing, IO Space
			default: ;
		endcase

		case (b_address[ADDRESS_SIZE-1:ADDRESS_SIZE-2])
			2'b00: b_out <= memory[b_address]; // Do not allow writes to code section
			2'b01, 2'b10:
			begin
				if (b_we)
				begin
					memory[b_address] <= b_writeData;
					b_out <= b_writeData;
				end
				else b_out <= memory[b_address];
			end
			// 11: // Do nothing, IO Space
			default: ;
		endcase
	end
endmodule
