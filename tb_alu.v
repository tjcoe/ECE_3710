//
//
//
//
//
//
module aluTest;
  // i/o
  reg  [15:0] a;
  reg  [15:0] b;
  reg  [3:0] opCode;
  reg  [3:0] opExt;
  wire [7:0] PSR;
  wire  [15:0] result;
  // for debugging
  integer error;
  
  alu UUT (
    .a(a),
	 .b(b),
	 .opCode(opCode),
	 .opExt(opExt),
	 .PSR(PSR), // 000CLFZN
	 .result(result)
  );
  
  
  initial begin
    error = 0;
	 
	 // start by testing all register instructions -> opCode = 0000
	 opCode = 4'b0000;
	 
	 
	 // test add instruction and all possible flag cases
	 opExt = 4'b0101;
	 a = 16'b0000_0000_0000_0001; // 1 + 2 = 3 no flags set
	 b = 16'b0000_0000_0000_0010;
	 #5
	 if (result != 3 | PSR != 0)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 a = 16'b1000_0000_0000_0000; // 32,768 + 32,768 = 65,536
	 b = 16'b1000_0000_0000_0000; // will set overflow and carry flags high & result should be 0 since it can't contain 16 bits.
	 #5
	 if (result !=0 | PSR != 8'b0001_0100)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 a = 16'b0111_1111_1111_1111; // this should flag the overflow bit but not the carry bit.
	 b = 16'b0000_0000_0000_0001; // since two positives will be adding to equal a negative here if numbers are signed.
	 #5
	 if (result != 32768 | PSR != 8'b0000_0100)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 a = 16'b1111_1111_1111_1111; // this is -1 + -1 = -2
	 b = 16'b1111_1111_1111_1111; // but if this were unsigned it would trip the carry bit. thus overflow flag low carry flag high
	 #5
    if (result != 65534 | PSR != 8'b0001_0000)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 
	 
	 // test sub and all possible flag cases
	 opExt = 4'b1001;
	 a = 3; // 3 - 4 = -1 or 65535 (unsigned value)
	 b = 4; // this will trigger the carry flag but not the overflow flag
	 #5
	 if (result != 65535 | PSR != 8'b0001_0000)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 a = 16'b1000_0000_0000_0000; // -32768 is the lowest number possible with 16-bits
	 b = 16'b0000_0000_0000_0001; // when we subract 1 this will set the overflow flag high but not the carry flag
	 #5
	 if (result != 32767 | PSR != 8'b0000_0100)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 a = 16'd3; // 3 - 1 = 2 no flags thrown
	 b = 16'd1;
	 #5
	 if (result != 2 | PSR != 8'b0000_0000)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 
	 
	 // test cmp and all possible flag cases
	 // this is very similar to sub except result is always 0 and different flags are set 
	 opExt = 4'b1011;
	 a = 16'd3; // 3 - 3 = 0 Z flag is set
	 b = 16'd3;
	 #5
	 if (result != 0 | PSR != 8'b0000_0010)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 a = 3; // 3 - 4 = -1 or 65535 (unsigned value)
	 b = 4; // this will trigger the L flag but not the N flag
	 #5
	 if (result != 0 | PSR != 8'b0000_1000)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 a = 16'b1000_0000_0000_0000; // -32768 is the lowest number possible with 16-bits
	 b = 16'b0000_0000_0000_0001; // when we subract 1 this will set the N flag high but not the L flag
	 #5
	 if (result != 0 | PSR != 8'b0000_0001)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 a = 16'd3; // 3 - 1 = 2 no flags thrown
	 b = 16'd1;
	 #5
	 if (result != 0 | PSR != 8'b0000_0000)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 
	 
	 //test and instruction. Does not affect flags
	 opExt = 4'b0001;
	 a = 16'b0000_0000_0000_1111;
	 b = 16'b0000_0000_0000_0010;
	 #5
	 if (result != 16'b0000_0000_0000_0000)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b",result);
		error = 1;
	 end
	 
	 
  end
endmodule
  