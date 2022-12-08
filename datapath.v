module datapath (input clk, reset, pcEn, instrWrite, regWrite, writeBackSelect, dataToWriteSelect, newAluInput, psrRegEn, sendPcAddr,
                 input [1:0] aluSrc1Select, aluSrc2Select, pcSrc,
                 input [15:0] memDataInbound, pcData,
                 output aluOutIsZero,
                 output [7:0] capturedPSR,
                 output [15:0] instr, memWriteData, outAddr);

    wire [3:0]  regDest, regSrc;
    wire [7:0]  PSR;
    wire [15:0] aluResult, nextPc, currentPc, regDataA, regDataB, a, b, aluSrc1, aluSrc2, writeBackData, writeBack, writeDataRF, storedMemData, immediate, incrPc, branchPc, pcAddr, memAddr;

    // register file address fields
    assign regDest = instr[11:8];
    assign regSrc  = instr[3:0];
    assign memAddr = b;
    assign memWriteData = a;
    assign immediate = (instr[7] == 0) ? {8'b0, instr[7:0]} : {8'b1, instr[7:0]};

    // load instruction from memory into a register
    flopenr instrReg(.clk(clk), .reset(reset), .en(instrWrite), .d(pcData), .q(instr));

    // other registers and muxes
    flopenr pcReg(.clk(clk), .reset(reset), .en(pcEn), .d(nextPc), .q(currentPc));
    flopenr aReg(.clk(clk), .reset(reset), .en(newAluInput), .d(regDataA), .q(a));
    flopenr bReg(.clk(clk), .reset(reset), .en(newAluInput), .d(regDataB), .q(b));

    flopenrlow #(8) psrReg(.clk(clk), .reset(reset), .en(psrRegEn), .d(PSR), .q(capturedPSR));

    flopr writeBackReg(.clk(clk), .reset(reset), .d(writeBack), .q(writeBackData));
    flopr mdr(.clk(clk), .reset(reset), .d(memDataInbound), .q(storedMemData));
    flopr mar(.clk(clk), .reset(reset), .d(currentPc<<4), .q(pcAddr));

    mux2 outAddrMux(.d0(memAddr), .d1(pcAddr), .sel(sendPcAddr), .res(outAddr));
    mux2 writeDataMux(.d0(writeBackData), .d1(currentPc), .sel(dataToWriteSelect), .res(writeDataRF));
    mux2 writeBackMux(.d0(aluResult), .d1(storedMemData), .sel(writeBackSelect), .res(writeBack));
    mux4 pcMux(.d0(incrPc), .d1(regDataB), .d2(branchPc), .d3(16'b0), .sel(pcSrc), .res(nextPc));
    mux4 aluSrc1Mux(.d0(currentPc), .d1(a), .d2(16'b0), .d3(16'b1), .sel(aluSrc1Select), .res(aluSrc1));
    mux4 aluSrc2Mux(.d0(b), .d1(immediate), .d2(16'b1), .d3(16'b0), .sel(aluSrc2Select), .res(aluSrc2));

   // instantiate the register file, ALU, and zerodetect on the ALU output
    registerfile rf(.clk(clk), .writeen(regWrite), .readaddrA(regDest), .readaddrB(regSrc), .writedata(writeDataRF), .outdataA(regDataA), .outdataB(regDataB));
    alu          alunit(.a(aluSrc1), .b(aluSrc2), .opCode(instr[15:12]), .opExt(instr[7:4]), .PSR(PSR), .result(aluResult));
    zerodetect   zd(.a(aluResult), .y(aluOutIsZero));
    SimpleAdder  Disp(.a(currentPc), .b(16'b1), .s(1'b0), .c(incrPc));
    SimpleAdder  PcIncr(.a(currentPc), .b(immediate), .s(1'b1), .c(branchPc));
endmodule