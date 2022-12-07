//  ALU module. Two inputs control the ALU. opCode and opExt.
//  Based on the control inputs logic is performed on a and b
//  and the result is output. Also a program register file is updated
//  and output based on the instruction.
//
//  Author: Tom Coe
module alu (
  input [15:0] a, // operand 1
  input [15:0] b, // operand 2
  input [3:0] opCode,
  input [3:0] opExt,
  output reg [7:0] PSR = 0, // 000CLFZN *this was recomened to be 8 bits in the assignment but there are only 5 flags?
  output reg [15:0] result  
);
  
  reg [16:0] carry = 0; // using the MSB of a 17 bit register to set the C flag
  reg [15:0] temp  = 0;
  reg [15:0] bExt  = 0;

  always @ *
  begin
    
	 case (opCode)
	 
	   4'b0000: //register
		begin
		  
		  case (opExt)
		    
			 4'b0100: // modi need mod 4 to index pixel location
			 begin
			  result = a%b;      // a mod b
			 end
		    4'b0101: // add
			 begin
			   result = a + b;
				carry  = a + b;
				PSR[4] = carry[16]; // sets the carry flag to the MSB of 'carry' reg
				PSR[2] = (a[15] ~^ b[15] && a[15] != result[15]) ? 1:0; // if two positives add to a negative or two negatives
			 end                                                        //	add to a positive -> trigger overflow bit
			 4'b1001: // sub
			 begin
			   result = a - b;
				PSR[4] = (a < b) ? 1:0; // carry(borrow) flag is set high if minuend is less than subtrahend
				PSR[2] = (a[15] ~^ ~b[15] && a[15] != result[15]) ? 1:0; // similar to overflow for adding.
				// subtraction is basically adding a negative so we can flip the MSB of b and use the same logic as above.
		    end
			 4'b1011: // cmp 
			 begin    // cmp uses essentially the same logic as sub but sets different flags and returns/writes no result.
			   temp = a - b; 
				PSR[3] = (a < b) ? 1:0; // sets the L flag if borrow occurs -> a < b
				PSR[0] = (a[15] ~^ ~b[15] && a[15] != temp[15]) ? 1:0; // sets the N flag is overflow occurs
			   PSR[1] = (temp == 0) ? 1:0;	// if a - b = 0 -> Z = 1 else Z = 0;
			 end
			 4'b1110: // MUL - multiply a * b. 
			 begin
			   result = a*b;
			 end
			 4'b0001: // and
			 begin
			   result = a & b; // bit-wise and
			 end
			 4'b0010: // or
			 begin
			   result = a | b; // bit-wise or
			 end
			 4'b0011: // xor
			 begin
			   result = a ^ b; // bit-wise xor
			 end
			 4'b1101: // mov
			 begin
			  result = b;      // passes through the source register value
			 end
		    default: PSR = 0;
		  endcase
		end
		4'b0001: // andi - same as and. Im is automatically zero extended
		begin
		  result = a & b;
		end
		4'b0010: // ORi - same as or. Im is automatically zero extended
	   begin
		  result = a | b;
		end
		4'b0011: // XORi - same as xor. No need to sign extend and imm is automatically zero extended
		begin
		  result = a ^ b;
		end
		4'b0100: // special
		begin
		  case (opExt)
		  
		    4'b0000: // load
			 begin
			   result = a + b; // assuming controller passes in Raddr value and Roffset value
			 end                // alu outputs the proper register addr to load -> a+b
			 4'b0100: // store
			 begin
			   result = a + b; // same assumptions as load
			 end
			 4'b1100: //jcond
			 begin // depending on flags will either jump to destination -> 0+dest or just add 1 to the PC -> PC + 1
			   result = a+b; // returns the address of next intruction
			 end
			 4'b1000: //jal
			 begin // similar to jcond but not dependent on flags
			   result = a+b;
			 end
			 default: PSR = 0;
		  endcase
		end
		4'b0101: // addi - same as add except Imm is sign extended.
		begin
		  bExt = $signed(b[7:0]); // sign extends 8-bit immediate value.
		  result = a + bExt;
		  carry  = a + bExt;
		  PSR[4] = carry[16]; // sets the carry flag to the MSB of 'carry' reg
		  PSR[2] = (a[15] ~^ bExt[15] && a[15] != result[15]) ? 1:0; // if two positives add to a negative or two negatives
		end
		4'b1001: // subi - same as sub except Imm is sign extended.
		begin
		  bExt = $signed(b[7:0]);
		  result = a - bExt;
		  PSR[4] = (a < bExt) ? 1:0; // carry(borrow) flag is set high if minuend is less than subtrahend
		  PSR[2] = (a[15] ~^ ~bExt[15] && a[15] != result[15]) ? 1:0; // similar to overflow for adding.
				// subtraction is basically adding a negative so we can flip the MSB of b and use the same logic as above.
		end
		4'b1011: // cmpi - same as cmp with Imm sign extended.
		begin
		  bExt = $signed(b[7:0]);
		  temp = a - bExt; 
		  PSR[3] = (a < bExt) ? 1:0; // sets the L flag if borrow occurs -> a < b
		  PSR[0] = (a[15] ~^ ~bExt[15] && a[15] != temp[15]) ? 1:0; // sets the N flag is overflow occurs
		  PSR[1] = (temp == 0) ? 1:0;	// if a - b = 0 -> Z = 1 else Z = 0;
		end
		4'b1101: // movi - same as mov. Passes through the reg value.
		begin
		  result = b;
		end
		4'b1000: // shift
		begin
		  case (opExt)
		  
		    4'b0100: // LSH - logical left shift b is 16-bit register value
			 begin
			   temp = ~b+1; // converts to positive in case b is negative
			   result = (b[15] == 0) ? a<<b:a>>temp; // right shifts by the flipped value of b if b is negative
			 end
			 4'b0000: // LSHI - logical left shift
			 begin
			   bExt = $signed(b[3:0]); // sign extends the 4-bit Imm value
				temp = ~bExt+1;
				result = (bExt[15] == 0) ? a<<b:a>>temp; // same as LSH but with sign extension for immediate value
			 end
			 4'b0001: // RSHI - logical right shift
			 begin
			   bExt = $signed(b[3:0]); // sign extends the 4-bit Imm value
				temp = ~bExt+1;
				result = a>>bExt;
				result = (bExt[15] == 0) ? a>>b:a<<temp; // same as LSHi but shift directions are opposite
			 end
			 default: result = 0;
		  endcase
		end
		4'b1111: //lui - left shifts 8-bits -> 0000000011111111 = 1111111100000000
		begin
		  result = b<<8;
		end
		default: PSR = 0;
	 endcase
	 
  end
endmodule
