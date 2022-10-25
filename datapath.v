module datapath (input clk, reset, pcEn, instrWrite, regWrite
                 input [1:0] pcSrc, aluSrc1Select, aluSrc2Select,
                 input [15:0] memData,
                 output aluOutIsZero,
                 output [15:0] instr, memWriteData);

    wire [3:0]  regDest, regSrc;
    wire [15:0] aluResult, nextPc, currentPc, regDataA, regDataB, a, aluSrc1, aluSrc2;

    // register file address fields
    assign regDest = instr[11:8];
    assign regSrc  = instr[3:0];

    // load instruction from memory into a register
    flopenr instrReg(.clk(clk), .reset(reset), .en(instrWrite), .d(memData), .q(instr));

    // other registers and muxes
    flopenr pcReg(.clk(clk), .reset(reset), .en(pcEn), .d(nextPc), .q(currentPc));
    flopr aReg(.clk(clk), .reset(reset), .d(regDataA), .q(a));
    flopr memWriteDataReg(.clk(clk), .reset(reset), .d(regDataB), .q(memWriteData));

    mux4 pcmux  (.d0(aluResult), .d1(), .d2(), .d3(0), .sel(pcSrc), .res(nextPc));
    mux4 aluSrc1(.d0(pc), .d1(a), .d2(memWriteData), .d3(), .sel(aluSrc1Select), .res(aluSrc1));
    mux4 aluSrc2(.d0(), .d1(16'b1), .d2(instr[7:0]), .d3(16'b0), .sel(aluSrc2Select), .res(aluSrc2));

   // instantiate the register file, ALU, and zerodetect on the ALU output
    registerfile rf(.clk(clk), .writeen(regWrite), .readaddrA(regDest), .readaddrB(regSrc), .writedata(), .outdataA(regDataA), .outdataB(B));
    alu          alunit(.a(aluSrc1), .b(aluSrc2), .opCode(instr[15:12]), .opExt(instr[7:4]), .PSR(), .result(aluResult));
    zerodetect   zd(.a(aluResult), .y(aluOutIsZero));
endmodule