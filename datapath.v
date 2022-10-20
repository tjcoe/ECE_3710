module datapath (input clk, reset);

    wire [15:0] aluResult, nextpc, currentpc;

    flopenr pcreg(.clk(clk), .reset(reset), .en(), .d(nextpc), .q(currentpc));

    registerfile rf(.clk(), .writeen(), .readaddrA(), .readaddrB(), .writedata(), .outdataA(), .outdataB());
    alu alunit(.a(), .b(), .opCode(), .opExt(), .PSR(), .result(aluResult));
    zerodetect zd(.a(aluResult), .y())
endmodule