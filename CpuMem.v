module CpuMem(input clk, reset);
    wire [15:0] memDataA, addrA, writeDataA, memDataB, addrB, WriteDataB;
    wire we, weB;

    cpu proc(.clk(clk), .reset(reset), .memDataInbound(memDataA), .pcData(memDataB),
             .memWrite(we), .memWriteData(writeDataA), .outAddr(addrA));
    ram_block mem(.a_address(addrA[15:4]), .b_address(addrB[15:4]), .a_writeData(writeDataA), .b_writeData(WriteDataB), .a_we(we), .b_we(weB), .clk(clk),
                  .a_out(memDataA), .b_out(memDataB));
endmodule