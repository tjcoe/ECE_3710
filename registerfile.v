// The register file is 16 bits wide, and 16 registers deep. 
// Dual ported (2 read ports) and 1 write port
//
// This will likely get compiled into a block RAM by 
// Quartus, so it can be initialized with a $readmemb function.
// In this case, all the values in the ram.dat file are 0
// to clear the registers to 0 on initialization
//
// @param WIDTH    			= width/size of the register file
// @param ADDR_BITS 			= size of bits to represent register file
// @param clk 					= input clock signal
// @param writeen				= write enable signal
// @param readaddrA 			= wire(s) connecting all registers that supply data
// @param readaddrB 			= wire(s) connecting all registers that supply data
// @param writedata 			= 
// @param outdataA 			= output data from register 1
// @param outdataB 			= output data from register 2

module registerfile #(parameter WIDTH = 16, ADDR_BITS = 4)
                (input                clk, writeen, 
                 input  [ADDR_BITS-1:0] readaddrA, readaddrB, 
                 input [WIDTH-1:0]   writedata,
					  output reg [WIDTH-1:0] outdataA, outdataB);

   reg  [WIDTH-1:0] REG_ARR [(1<<ADDR_BITS)-1:0]; //(1<<ADDR_BITS)-1:0

	initial begin
		$readmemb("C:\\Users\\tommy\\OneDrive\\Documents\\School\\22-23\\Fall 2022\\ECE 3710\\project\\ECE_3710\\reg_initial.bin", REG_ARR);
	end
	
	always @ (posedge clk)
	begin
		if (writeen && readaddrA != 0) begin
			REG_ARR[readaddrA] <= writedata;
			outdataA <= writedata;
		end
		else begin
			outdataA <= REG_ARR[readaddrA];
		end 
		outdataB <= REG_ARR[readaddrB];
	end
	
//	  assign outdataA = readaddrA ? REG_ARR[readaddrA] : 0;
//   assign outdataB = readaddrB ? REG_ARR[readaddrB] : 0;
	
endmodule
