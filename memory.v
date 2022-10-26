
module io_block #(parameter DATA_SIZE = 16, parameter ADDRESS_SIZE = 12)
	(
		input [(ADDRESS_SIZE - 1) : 0] a_address, b_address,
		input [(DATA_SIZE - 1) : 0] 	 a_writeData, b_writeData,
		input a_we, b_we, clk,
		input [9:0] switches,
		input [4:0] pushButtons,
		output reg [(DATA_SIZE - 1) : 0] a_out, b_out
	);

	reg [9:0] leds;
	reg [(7*2 - 1):0] dualHexSegment[2:0];


	wire [ADDRESS_SIZE + 4:0] a_fullAddress = { a_address, 4'b0000 };
	wire [ADDRESS_SIZE + 4:0] b_fullAddress = { b_address, 4'b0000 };
	
	always@(posedge clk)
	begin
		if(a_address[ADDRESS_SIZE-1:ADDRESS_SIZE-2] == 2'b11)
		begin
			case (a_address)
				12'hFFF: // LEDS
				begin
					if (a_we)
					begin
						leds <= a_writeData[9:0];
					end
					a_out <= 0;
				end

				12'hFFE: // Switches
					a_out <= { 6'b000000, switches };
				

				12'hFFD, 12'hFFC, 12'hFFB: // Right Dual Hex Display 13:7 left hex, 6:0 right hex
				begin
					if (a_we)
					begin
						dualHexSegment[a_address[1:0]] <= a_writeData[6:0];
					end
					a_out <= 0;
				end

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
		$readmemb("MemoryInit.data", memory);
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
			00: a_out <= memory[a_address]; // Do not allow writes to code section
			01, 10:
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
			00: b_out <= memory[b_address]; // Do not allow writes to code section
			01, 10:
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