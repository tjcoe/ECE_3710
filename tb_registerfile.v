module tb_registerfile();
	
	reg clk = 0; 
	reg writeen = 0;
	reg [3:0] readaddrA = 4'b0;
	reg [3:0] readaddrB = 4'b0;
	reg [15:0] writedata = 16'b0;
	wire [15:0] outdataA = 16'b0;
	wire [15:0] outdataB = 16'b0;
	
	registerfile UUT(.clk(clk), .writeen(writeen), .readaddrA(readaddrA), 
						  .readaddrB(readaddrB), .writedata(writedata), .outdataA(outdataA), 
						  .outdataB(outdataB));	 
	
	integer i, j;
	
	initial begin
		clk = 0;
		
		for (i = 0; i < 16; i = i + 1) begin
			readaddrA = i;
			for (j = 0; j < 65_536; j = j + 1) begin
			
				#10;
				
				writedata = j;
				writeen = 1'd1;
				clk = 1'b1;
				#10;
				clk = 1'b0;
				
				if (readaddrA == 0 && outdataA != 0) begin
					$display("Register A [%d] data incorrect: expected %d, got %d.", i, j, outdataA);
				end
				else if (outdataA != j && readaddrA != 0) begin
					$display("Register A [%d] data incorrect: expected %d, got %d.", i, j, outdataA);
				end
				
				writeen = 1'b0;
				
				readaddrA = i;
				readaddrB = i;
				
				#10;
				
				clk = 1'b1;
				
				#10;
				
				clk = 1'b0;
				if (readaddrA == 0 && outdataA != 0) begin
					$display("Register A [%d] data incorrect: expected %d, got %d.", i, j, outdataA);
				end
				else if (outdataA != j && readaddrA != 0) begin
					$display("Register A [%d] data incorrect: expected %d, got %d.", i, j, outdataA);
				end
				
				
				if (readaddrB == 0 && outdataB != 0) begin
					$display("Register B [%d] data incorrect: expected %d, got %d.", i, j, outdataB);
				end
				else if (outdataB != j && readaddrB != 0) begin
					$display("Register B [%d] data incorrect: expected %d, got %d.", i, j, outdataB);
				end
				
			end
		end
		$display("******************Sim Done*******************");
	end
endmodule
