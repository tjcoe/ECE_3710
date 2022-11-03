module cpu(input clk, reset,
           input [15:0] memDataInbound,
           output memWrite,
           output [15:0] memWriteData, memAddr);

    wire pcEn, instrWrite, regWrite, writeBackSelect, dataToWriteSelect, pcSrc, newAluInput, zero;
    wire [1:0] aluSrc1Select, aluSrc2Select;
    wire [7:0] PSR;
    wire [15:0] instr, pcAddr;

    datapath dp(.clk(clk), .reset(reset), .pcEn(pcEn), .instrWrite(instrWrite), .regWrite(regWrite), // inputs
                .writeBackSelect(writeBackSelect), .dataToWriteSelect(dataToWriteSelect), .pcSrc(pcSrc),
                .newAluInput(newAluInput), .aluSrc1Select(aluSrc1Select), .aluSrc2Select(aluSrc2Select),
                .memDataInbound(memDataInbound),
                .aluOutIsZero(zero), .PSR(PSR), .instr(instr), .memWriteData(memWriteData), // outputs
                .memAddr(memAddr), .pcAddr(pcAddr));

    controller ctrl(.clk(clk), .reset(reset), .zero(zero), .op(instr[15:12]), .opExt(instr[7:4]), // inputs
                    .cond(instr[11:8]),
                    .memWrite(memWrite), .pcEn(pcEn), .writeBackSelect(writeBackSelect), // outputs
                    .dataToWriteSelect(dataToWriteSelect), .pcSrc(pcSrc), .newAluInput(newAluInput),
                    .regWrite(regWrite), .instrWrite(instrWrite), .aluSrc1Sel(aluSrc1Select),
                    .aluSrc2Sel(aluSrc2Select));
endmodule;