module tb_debuggingAsm();
    reg clk, reset;

    wire we, weB;
    wire [15:0] memDataA, addrA, writeDataA, memDataB, addrB, WriteDataB;
	wire [15:0] memDataAram;
	wire [15:0] memDataAio;
	wire [15:0] memDataBram;
	wire [15:0] memDataBio;

	wire [15:0] pixelAddress;
	wire [15:0] bufOut;

    //CpuMem uut(clk, reset, start, ps2_clk, ps2_data, hSync, vSync, bright, clk_25Mhz, VGA_SYNC_N, red, green, blue, btns, hexDisplays);

    assign memDataA = addrA[15:14] == 2'b11 ? memDataAio : memDataAram;
	assign memDataB = addrB[15:14] == 2'b11 ? memDataBio : memDataBram;

    cpu proc(.clk(clk), .reset(reset), .memDataInbound(memDataA), .memWrite(we), .memWriteData(writeDataA), .outAddr(addrA));

    ram_block mem(
		.a_address(addrA[15:4]), 
		.b_address(pixelAddress[15:4]), 
		.a_writeData(writeDataA), 
		.b_writeData(WriteDataB), 
		.a_we(we), 
		.b_we(weB), 
		.clk(clk),
        .a_out(memDataAram), 
		.b_out(bufOut)
		);

    // y 80+ is canvas
	 // x < 213 red
	 // x > 213 and x < 426 green
	 // else blue
	 io_block io_block(
		.a_address(addrA[15:4]), 
		.b_address(addrB[15:4]), 
		.a_writeData(writeDataA), 
		.b_writeData(WriteDataB), 
		.a_we(we), 
		.b_we(weB), 
		.clk(clk),
		.lmb(1),
		.mmb(0),
		.rmb(0),
		.mouse_x(16'd479),
		.mouse_y(16'd80),
		.a_out(memDataAio), 
		.b_out(memDataBio)
		);

    initial begin
        reset = 1;
        #22 reset = 0;
        #22 reset = 1;
    end

    always begin
        clk <= 0; #5 clk <= 1; #5;
    end
endmodule