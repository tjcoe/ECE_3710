module tb_cpu();
    reg clk, reset;
    reg [15:0] memDataInbound;

    wire memWrite;
    wire [15:0] memWriteData, memAddr;

    cpu uut(.clk(clk), .reset(reset), .memDataInbound(memDataInbound),
            .memWrite(memWrite), .memWriteData(memWriteData), .memAddr(memAddr));

    initial begin
        reset <= 1; memDataInbound <= 16'b0;
        #22 reset <= 0;
        #22 reset <= 1;
    end

    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    initial begin
        // ADDI $1 10
        memDataInbound <= 16'b0101000100001010;
    end
endmodule