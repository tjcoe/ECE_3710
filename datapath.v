module datapath (input clk, reset, pcEn, instrWrite, regWrite, writeBackSelect, dataToWriteSelect, pcSrc, newAluInput,
                 input [1:0] aluSrc1Select, aluSrc2Select,
                 input [15:0] memDataInbound,
                 output aluOutIsZero,
                 output [7:0] PSR,
                 output [15:0] instr, memWriteData, memAddr, pcAddr);

    wire [3:0]  regDest, regSrc;
    wire [15:0] aluResult, nextPc, currentPc, regDataA, regDataB, a, b, aluSrc1, aluSrc2, writeBackData, writeBack, writeDataRF, storedMemData, immediate;

    // register file address fields
    assign regDest = instr[11:8];
    assign regSrc  = instr[3:0];
    assign memAddr = b;
    assign memWriteData = a;
    assign immediate = (instr[7] == 0) ? {8'b0, instr[7:0]} : {8'b1, instr[7:0]};

    // load instruction from memory into a register
    flopenr instrReg(.clk(clk), .reset(reset), .en(instrWrite), .d(memDataInbound), .q(instr));

    // other registers and muxes
    flopenr pcReg(.clk(clk), .reset(reset), .en(pcEn), .d(nextPc), .q(currentPc));
    flopenr aReg(.clk(clk), .reset(reset), .en(newAluInput), .d(regDataA), .q(a));
    flopenr bReg(.clk(clk), .reset(reset), .en(newAluInput), .d(regDataB), .q(b));
    flopr writeBackReg(.clk(clk), .reset(reset), .d(writeBack), .q(writeBackData));
    flopr mdr(.clk(clk), .reset(reset), .d(memDataInbound), .q(storedMemData));
    flopr mar(.clk(clk), .reset(reset), .d(currentPc<<4), .q(pcAddr));

    mux2 writeDataMux(.d0(writeBackData), .d1(currentPc), .sel(dataToWriteSelect), .res(writeDataRF));
    mux2 writeBackMux(.d0(aluResult), .d1(storedMemData), .sel(writeBackSelect), .res(writeBack));
    mux2 pcMux(.d0(aluResult), .d1(b), .sel(pcSrc), .res(nextPc));
    mux4 aluSrc1Mux(.d0(currentPc), .d1(a), .d2(16'b0), .d3(16'b1), .sel(aluSrc1Select), .res(aluSrc1));
    mux4 aluSrc2Mux(.d0(b), .d1(immediate), .d2(16'b1), .d3(16'b0), .sel(aluSrc2Select), .res(aluSrc2));

   // instantiate the register file, ALU, and zerodetect on the ALU output
    registerfile rf(.clk(clk), .writeen(regWrite), .readaddrA(regDest), .readaddrB(regSrc), .writedata(writeDataRF), .outdataA(regDataA), .outdataB(regDataB));
    alu          alunit(.a(aluSrc1), .b(aluSrc2), .opCode(instr[15:12]), .opExt(instr[7:4]), .PSR(PSR), .result(aluResult));
    zerodetect   zd(.a(aluResult), .y(aluOutIsZero));
    //SimpleAdder  Disp(.a(), .b(), .c());
    //SimpleAdder  PcIncr();
endmodule