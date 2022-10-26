module datapath (input clk, reset, pcEn, instrWrite, regWrite, writeBackSelect, dataToWriteSelect,
                 input [1:0] pcSrc, aluSrc1Select, aluSrc2Select,
                 input [15:0] instrMemData,
                 output aluOutIsZero,
                 output [15:0] instr, memWriteData, memAddr);

    wire [3:0]  regDest, regSrc;
    wire [7:0]  PSR;
    wire [15:0] aluResult, nextPc, currentPc, regDataA, regDataB, a, b, aluSrc1, aluSrc2, writeBackData, writeBack, writeDataRF;

    // register file address fields
    assign regDest = instr[11:8];
    assign regSrc  = instr[3:0];
    assign memAddr = b; // what size should this be??
    assign memWriteData = a;

    // load instruction from memory into a register
    flopenr instrReg(.clk(clk), .reset(reset), .en(instrWrite), .d(instrMemData), .q(instr));

    // other registers and muxes
    flopenr pcReg(.clk(clk), .reset(reset), .en(pcEn), .d(nextPc), .q(currentPc));
    flopr aReg(.clk(clk), .reset(reset), .d(regDataA), .q(a));
    flopr bReg(.clk(clk), .reset(reset), .d(regDataB), .q(b));
    flopr writeBackReg(.clk(clk), .reset(reset), .d(writeBack), .q(writeBackData));

    mux2 writeDataMux(.d0(writeBackData), .d1(currentPc), .sel(dataToWriteSelect), .res(writeDataRF));
    mux2 writeBackMux(.d0(aluResult), .d1(/*data from mem*/), .sel(writeBackSelect), .res(writeBack));
    mux4 pcMux  (.d0(aluResult), .d1(b), .d2(), .d3(), .sel(pcSrc), .res(nextPc));
    mux4 aluSrc1(.d0(currentPc), .d1(a), .d2(16'b0), .d3(), .sel(aluSrc1Select), .res(aluSrc1));
    mux4 aluSrc2(.d0(b), .d1(instr[7] == 0 : {8'b0, instr[7:0]} : {8'b1, instr[7:0]}), .d2(16'b1), .d3(16'b0), .sel(aluSrc2Select), .res(aluSrc2));

   // instantiate the register file, ALU, and zerodetect on the ALU output
    registerfile rf(.clk(clk), .writeen(regWrite), .readaddrA(regDest), .readaddrB(regSrc), .writedata(writeDataRF), .outdataA(regDataA), .outdataB(regDataB));
    alu          alunit(.a(aluSrc1), .b(aluSrc2), .opCode(instr[15:12]), .opExt(instr[7:4]), .PSR(PSR), .result(aluResult));
    zerodetect   zd(.a(aluResult), .y(aluOutIsZero));
endmodule