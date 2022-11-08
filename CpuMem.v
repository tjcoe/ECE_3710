module CpuMem(input clk, reset);
    wire [15:0] memDataA, addrA, writeDataA, memDataB, addrB, WriteDataB;
    wire weA, weB;

    cpu proc(.clk(clk), .reset(reset), .memDataInbound(memDataA),
             .memWrite(we), .memWriteData(writeDataA), .memAddr(addrA));
    memory ram_block(.a_address(addrA), .b_address(addrB), .a_writeData(writeDataA), .b_writeData(WriteDataB), .a_we(weA), .b_we(weB), .clk(clk),
                     .a_out(memDataA), .b_out(memDataB));
endmodule