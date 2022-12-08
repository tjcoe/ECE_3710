module cpu(input clk, reset,
           input [15:0] memDataInbound, pcData,
           output memWrite,
           output [15:0] memWriteData, outAddr);

    wire pcEn, instrWrite, regWrite, writeBackSelect, dataToWriteSelect, newAluInput, zero, psrRegEn, sendPcAddr;
    wire [1:0] aluSrc1Select, aluSrc2Select, pcSrc;
    wire [7:0] PSR;
    wire [15:0] instr;

    datapath dp(.clk(clk), .reset(reset), .pcEn(pcEn), .instrWrite(instrWrite), .regWrite(regWrite), // inputs
                .writeBackSelect(writeBackSelect), .dataToWriteSelect(dataToWriteSelect), .pcSrc(pcSrc),
                .newAluInput(newAluInput), .psrRegEn(psrRegEn), .sendPcAddr(sendPcAddr), .aluSrc1Select(aluSrc1Select),
                .aluSrc2Select(aluSrc2Select), .memDataInbound(memDataInbound), .pcData(pcData),
                .aluOutIsZero(zero), .capturedPSR(PSR), .instr(instr), .memWriteData(memWriteData), // outputs
                .outAddr(outAddr));

    controller ctrl(.clk(clk), .reset(reset), .zero(zero), .op(instr[15:12]), .opExt(instr[7:4]), // inputs
                    .cond(instr[11:8]), .PSR(PSR),
                    .memWrite(memWrite), .pcEn(pcEn), .writeBackSelect(writeBackSelect), // outputs
                    .dataToWriteSelect(dataToWriteSelect), .pcSrc(pcSrc), .newAluInput(newAluInput),
                    .psrRegEn(psrRegEn), .regWrite(regWrite), .instrWrite(instrWrite), .sendPcAddr(sendPcAddr),
                    .aluSrc1Sel(aluSrc1Select), .aluSrc2Sel(aluSrc2Select));
endmodule