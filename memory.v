module io_block #(parameter DATA_SIZE = 16, parameter ADDRESS_SIZE = 12)
	(
		input [(ADDRESS_SIZE - 1) : 0] a_address, b_address,
		input [(DATA_SIZE - 1) : 0] 	 a_writeData, b_writeData,
		input a_we, b_we, clk,
		input lmb, mmb, rmb,
		input [15:0] mouse_x, mouse_y,
		output [(DATA_SIZE - 1) : 0] a_out, b_out
	);

	io_block_impl
	io_block_a
	(
		.address(a_address),
		.writeData(a_writeData),
		.we(a_we),
		.clk(clk),
		.lmb(lmb),
		.mmb(mmb),
		.rmb(rmb),
		.mouse_x(mouse_x),
		.mouse_y(mouse_y),
		.out(a_out)
	);
	
	
	io_block_impl
	io_block_b
	(
		.address(b_address),
		.writeData(b_writeData),
		.we(b_we),
		.clk(clk),
		.lmb(lmb),
		.mmb(mmb),
		.rmb(rmb),
		.mouse_x(mouse_x),
		.mouse_y(mouse_y),
		.out(b_out)
	);
	
endmodule

module io_block_impl #(parameter DATA_SIZE = 16, parameter ADDRESS_SIZE = 12)
	(
		input [(ADDRESS_SIZE - 1) : 0] address,
		input [(DATA_SIZE - 1) : 0] 	 writeData,
		input we, clk,
		input lmb, mmb, rmb,
		input [15:0] mouse_x, mouse_y,
		output reg [(DATA_SIZE - 1) : 0] out
	);
	
	always@(posedge clk)
	begin
		if(address[ADDRESS_SIZE-1:ADDRESS_SIZE-2] == 2'b11)
		begin
			case (address)
					
				12'hFF9:
					out <= { 13'b0000000000000, lmb, mmb, rmb };
					
				12'hFF8:
					out <= mouse_x;
				
				12'hFF7:
					out <= mouse_y;
				
				default: out <= 0;
			endcase
		end
	end
endmodule
	


module ram_block #(parameter DATA_SIZE = 16, parameter ADDRESS_SIZE = 12)
	(
		input [(ADDRESS_SIZE - 1) : 0] a_address, b_address, c_address,
		input [(DATA_SIZE - 1) : 0] 	 a_writeData, b_writeData,
		input a_we, b_we, clk,
		output reg [(DATA_SIZE - 1) : 0] a_out, b_out, c_out
	);
	
	
	reg [(DATA_SIZE - 1) : 0] memory[(ADDRESS_SIZE - 1) : 0];
	
	initial 
	begin
		$readmemb("C:\\Users\\Isaac\\Documents\\ECE3710\\project\\ECE_3710\\Paint.bin", memory);
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