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
	 if (PSR != 8'b0000_0010)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("PSR: %b", PSR);
		error = 1;
	 end
	 a = 3; // 3 - 4 = -1 or 65535 (unsigned value)
	 b = 4; // this will trigger the L flag but not the N flag
	 #5
	 if (PSR != 8'b0000_1000)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("PSR: %b", PSR);
		error = 1;
	 end
	 a = 16'b1000_0000_0000_0000; // -32768 is the lowest number possible with 16-bits
	 b = 16'b0000_0000_0000_0001; // when we subract 1 this will set the N flag high but not the L flag
	 #5
	 if (PSR != 8'b0000_0001)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("PSR: %b", PSR);
		error = 1;
	 end
	 a = 16'd3; // 3 - 1 = 2 no flags thrown
	 b = 16'd1;
	 #5
	 if (PSR != 8'b0000_0000)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("PSR: %b", PSR);
		error = 1;
	 end
	 
	 
	 //test and instruction. Does not affect flags
	 opExt = 4'b0001;
	 a = 16'b0000_0000_0000_1111;
	 b = 16'b0000_0000_0000_0010;
	 #5
	 if (result != 16'b0000_0000_0000_0010)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b",result);
		error = 1;
	 end
	 
	 
	 //test or instruction. Does not affect flags
	 opExt = 4'b0010;
	 a = 16'b0000_0000_0000_1011;
	 b = 16'b0000_0000_0000_0101;
	 #5
	 if (result != 16'b0000_0000_0000_1111)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b",result);
		error = 1;
	 end
	 
	 
	 // test xor instruction
	 opExt = 4'b0011;
	 a = 16'b1000_0000_0000_1010;
	 b = 16'b1000_0000_0000_0101;
	 #5
	 if (result != 16'b0000_0000_0000_1111)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b",result);
		error = 1;
	 end
	 
	 
	 // test mov instruction
	 opExt = 4'b1101;
	 a = 16'b1000_0000_0000_1010;
	 b = 16'b1000_0000_0000_0101;
	 #5
	 if (result != 16'b1000_0000_0000_0101)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b",result);
		error = 1;
	 end
	 
	 
	 // test andi
	 opCode = 4'b0001;
	 a = 16'b0000_0000_0000_1111;
	 b = 8'b0000_0110;
	 #5
	 if (result != 16'b0000_0000_0000_0110)
	 begin
	   $display("Error with opCode: %b", opCode);
		$display("Result: %b",result);
		error = 1;
	 end
	 
	 
	 // test ORi
	 opCode = 4'b0010;
	 a = 16'b1000_0000_0000_1111;
	 b = 8'b0001_0110;
	 #5
	 if (result != 16'b1000_0000_0001_1111)
	 begin
	   $display("Error with opCode: %b", opCode);
		$display("Result: %b",result);
		error = 1;
	 end
	 
	 
	 // test XORi
	 opCode = 4'b0011;
	 a = 16'b1000_0000_0000_1111;
	 b = 8'b0001_0110;
	 #5
	 if (result != 16'b1000_0000_0001_1001)
	 begin
	   $display("Error with opCode: %b", opCode);
		$display("Result: %b",result);
		error = 1;
	 end
	 
	 
	 // test special instructions
	 opCode = 4'b0100; // these are basically just add instructions
	                   // the data path will feed correct register values based on flags / pc / cond
	 // test load
	 opExt = 4'b0000;
	 a = 16'b1000_0000_0000_1010;
	 b = 16'b0000_0000_0000_0101;
	 #5
	 if (result != 16'b1000_0000_0000_1111)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b",result);
		error = 1;
	 end
	 
	 
	 // test store
	 opExt = 4'b0100;
	 a = 16'b1000_0000_0000_1010;
	 b = 16'b0000_0000_0000_0101;
	 #5
	 if (result != 16'b1000_0000_0000_1111)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b",result);
		error = 1;
	 end
	 
	 
	 // test jcond
	 opExt = 4'b1100;
	 a = 16'b1000_0000_0000_1010;
	 b = 16'b0000_0000_0000_0101;
	 #5
	 if (result != 16'b1000_0000_0000_1111)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b",result);
		error = 1;
	 end
	 
	 
	 // test jal
	 opExt = 4'b1000;
	 a = 16'b1000_0000_0000_1010;
	 b = 16'b0000_0000_0000_0101;
	 #5
	 if (result != 16'b1000_0000_0000_1111)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b",result);
		error = 1;
	 end
	 
	 
	 // test addi
	 opCode = 4'b0101;
	 opExt = 4'b0000;
	 a = 16'b0000_0000_0000_0001; // 1 + 2 = 3 no flags set
	 b = 8'b0000_0010;
	 #5
	 if (result != 3 | PSR != 0)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 a = 16'b1000_0000_0000_0000;
	 b = 8'b1000_0000; // will set overflow and carry flags high since this will sign extend to 1111_1111_1000_000
	 #5
	 if (result !=16'b0111_1111_1000_0000 | PSR != 8'b0001_0100)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 a = 16'b0111_1111_1111_1111; // this should flag the overflow bit but not the carry bit.
	 b = 8'b0000_0001; // since two positives will be adding to equal a negative here if numbers are signed.
	 #5
	 if (result != 32768 | PSR != 8'b0000_0100)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 a = 16'b1111_1111_1111_1111; // this is -1 + -1 = -2 with signed integers. Doens't trip overflow
	 b = 8'b1111_1111; // but if this were unsigned it would trip the carry bit.
	 #5
    if (result != 65534 | PSR != 8'b0001_0000)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 
	 // test subi and all possible flag cases
	 opCode = 4'b1001;
	 a = 16'b0000_0000_0000_0011; // 3 - 4 = -1 or 65535 (unsigned value)
	 b = 8'b0000_0100; // this will trigger the carry flag but not the overflow flag
	 #5
	 if (result != 65535 | PSR != 8'b0001_0000)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 a = 16'b1000_0000_0000_0000; // -32768 is the lowest number possible with 16-bits
	 b = 8'b0000_0001; // when we subract 1 this will set the overflow flag high but not the carry flag
	 #5
	 if (result != 32767 | PSR != 8'b0000_0100)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 a = 16'b0000_0000_0000_0011; // 3 - 1 = 2 no flags thrown
	 b = 8'b0000_0001;
	 #5
	 if (result != 2 | PSR != 8'b0000_0000)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %d, PSR: %b", result,PSR);
		error = 1;
	 end
	 
	 
	 // test cmpi and all possible flag cases
	 // this is very similar to subi except result is always 0 and different flags are set (z, l, n instead of c,f)
	 opCode = 4'b1011;
	 a = 16'b0000_0000_0000_0011; // 3 - 3 = 0 Z flag is set
	 b = 8'b0000_0011;
	 #5
	 if (PSR != 8'b0000_0010)
	 begin
	   $display("Error with opCode: %b", opCode);
		$display("PSR: %b", PSR);
		error = 1;
	 end
	 a = 16'b0000_0000_0000_0011; // 3 - 4 = -1 or 65535 (unsigned value)
	 b = 8'b0000_0100; // this will trigger the L flag but not the N flag
	 #5
	 if (PSR != 8'b0000_1000)
	 begin
	   $display("Error with opCode: %b", opCode);
		$display("PSR: %b", PSR);
		error = 1;
	 end
	 a = 16'b1000_0000_0000_0000; // -32768 is the lowest number possible with 16-bits
	 b = 8'b0000_0001; // when we subract 1 this will set the N flag high but not the L flag
	 #5
	 if (PSR != 8'b0000_0001)
	 begin
	   $display("Error with opCode: %b", opCode);
		$display("PSR: %b", PSR);
		error = 1;
	 end
	 a = 16'b0000_0000_0000_0011; // 3 - 1 = 2 no flags thrown
	 b = 8'b0000_0001;
	 #5
	 if (PSR != 8'b0000_0000)
	 begin
	   $display("Error with opCode: %b", opCode);
		$display("PSR: %b", PSR);
		error = 1;
	 end
	 
	 
	 // test movi
	 opCode = 4'b1101; // just passes through immediate argument
	 a = 16'b1000_0000_0000_1010;
	 b = 16'b0000_0101;
	 #5
	 if (result != 16'b0000_0000_0000_0101)
	 begin
	   $display("Error with opCode: %b", opCode);
		$display("Result: %b",result);
		error = 1;
	 end
	 
	 
	 // test shift instructions
	 opCode = 4'b1000;
	 // test LHS logical left shift with register value
	 opExt = 4'b0100;
	 a = 16'b0000_0000_0000_0001; // 1 shifted left by 3 -> 0001 = 1000
	 b = 16'b0000_0000_0000_0011;
	 #5
	 if (result != 8)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b", result);
		error = 1;
	 end
	 a = 16'b0000_0000_0000_0010; // 1 shifted left by -1 -> 0010 = 0001
	 b = 16'b1111_1111_1111_1111; 
	 #5
	 if (result != 1)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b", result);
		error = 1;
	 end
	 
	 
	 // test LHSi logical left shift with immediate value
	 opExt = 4'b0000;
	 a = 16'b0000_0000_0000_0001; // 1 shifted left by 3 -> 0001 = 1000
	 b = 4'b0011;
	 #5
	 if (result != 8)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b", result);
		error = 1;
	 end
	 a = 16'b0000_0000_0000_0010; // 1 shifted left by -1 -> 0010 = 0001
	 b = 4'b1111; 
	 #5
	 if (result != 1)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b", result);
		error = 1;
	 end
	 
	 
	 // test RHSi logical right shift with immediate value
	 opExt = 4'b0001;
	 a = 16'b0000_0000_0000_1000; // 1 shifted right by 3 -> 1000 = 0001
	 b = 4'b0011;
	 #5
	 if (result != 1)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b", result);
		error = 1;
	 end
	 a = 16'b0000_0000_0000_0001; // 1 shifted right by -1 -> 0001 = 0010
	 b = 4'b1111; 
	 #5
	 if (result != 2)
	 begin
	   $display("Error with opCode: %b, opExt: %b", opCode, opExt);
		$display("Result: %b", result);
		error = 1;
	 end
	 
	 
	 // test LUI
	 opCode = 4'b1111;
	 opExt = 4'b0000;
	 b = 16'b0000_0000_1111_1111; // logical left shift by 8
	 #5
	 if (result != 16'b1111_1111_0000_0000)
	 begin
	   $display("Error with opCode: %b", opCode);
		$display("Result: %b", result);
		error = 1;
	 end
	 
	 
	 #5
	 if (error == 0) $display("Passed ALU test bench.");
  end
endmodule
  