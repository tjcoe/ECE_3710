module tb_datapath();
    reg clk, reset, pcEn, instrWrite, regWrite, writeBackSelect, dataToWriteSelect, pcSrc, newAluInput;
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
                 .newAluInput(newAluInput),
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
        pcEn <= 1; reset <= 1; instrWrite <= 1; regWrite <= 0; writeBackSelect <= 0; dataToWriteSelect <= 1; pcSrc <= 0; newAluInput <= 0;
        aluSrc1Select <= 2'b0; aluSrc2Select <= 2'b10;
        memDataInbound <= 16'b0;
        #22 reset <= 0; pcEn <= 1; instrWrite <= 0;
        #22 reset <= 1; pcEn <= 0; instrWrite <= 1;
    end

    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    initial begin
        // ADDI $1 10
        memDataInbound <= 16'b0101000100001010;
        instrWrite <= 1;
        newAluInput <= 1;
        #10
        instrWrite <= 0;
        if (instr == 16'b0101000100001010)
            $display("Successfully loaded instruction");
        else
            $display("Instruction load error: %b", instr);
        #10
        newAluInput <= 0;
        aluSrc1Select <= 2'b01;
        aluSrc2Select <= 2'b01;
        #10
        writeBackSelect <= 0;
        #10
        dataToWriteSelect <= 0;
        #10
        regWrite <= 1;
        #1000
        regWrite <= 0;

        // ADD $1 $2
        /* memDataInbound <= 16'b0000001001010001;
        instrWrite <= 1;
        newAluInput <= 1;
        #10
        instrWrite <= 0;
        #10
        newAluInput <= 0;
        aluSrc1Select <= 2'b01;
        aluSrc2Select <= 2'b00;
        #10
        regWrite <= 1;
        #1000
        regWrite <= 0; */
    end
endmodule