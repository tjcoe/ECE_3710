module tb_datapath();
    reg clk, reset, pcEn, instrWrite, regWrite, writeBackSelect, dataToWriteSelect, pcSrc;
    reg [1:0] aluSrc1Select, aluSrc2Select;
    reg [15:0] memDataInbound;

    wire aluOutIsZero;
    wire [7:0] PSR;
    wire [15:0] instr, memWriteData, memAddr, pcAddr;

    datapath uut(.clk(clk),
                 .reset(reset),
                 .pcEn(pcEn),
                 .instrWrite(instrWrite),
                 .regWrite(regWrite),
                 .writeBackSelect(writeBackSelect),
                 .dataToWriteSelect(dataToWriteSelect),
                 .pcSrc(pcSrc),
                 .aluSrc1Select(aluSrc1Select),
                 .aluSrc2Select(aluSrc2Select),
                 .memDataInbound(memDataInbound),
                 .aluOutIsZero(aluOutIsZero),
                 .PSR(PSR),
                 .instr(instr),
                 .memWriteData(memWriteData),
                 .memAddr(memAddr),
                 .pcAddr(pcAddr));

    initial begin
        pcEn <= 1; reset <= 1; instrWrite <= 1; regWrite <= 0; writeBackSelect <= 0; dataToWriteSelect <= 1; pcSrc <= 0;
        aluSrc1Select <= 2'b0; aluSrc2Select <= 2'b10;
        memDataInbound <= 16'b0;
        #22 reset <= 0; pcEn <= 0; instrWrite <= 0;
        #22 reset <= 1; pcEn <= 1; instrWrite <= 1;
    end

    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    initial begin
        
    end
endmodule