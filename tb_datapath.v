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
        #20
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
        memDataInbound <= 16'b0000001001010001;
        instrWrite <= 1;
        newAluInput <= 1;
        #10
        instrWrite <= 0;
        #20
        newAluInput <= 0;
        aluSrc1Select <= 2'b01;
        aluSrc2Select <= 2'b00;
        #10
        regWrite <= 1;
        #1000
        regWrite <= 0;

        // SUB $2 $1
        memDataInbound <= 16'b0000000110010010;
        instrWrite <= 1;
        newAluInput <= 1;
        #10
        instrWrite <= 0;
        #20
        newAluInput <= 0;
        aluSrc1Select <= 2'b01;
        aluSrc2Select <= 2'b00;
        #10
        regWrite <= 1;
        #1000
        regWrite <= 0;

        // SUBI 5 $2
        memDataInbound <= 16'b1001001000000101;
        instrWrite <= 1;
        newAluInput <= 1;
        #10
        instrWrite <= 0;
        #20
        newAluInput <= 0;
        aluSrc1Select <= 2'b01;
        aluSrc2Select <= 2'b01;
        #10
        regWrite <= 1;
        #1000
        regWrite <= 0;

        // CMP $0 $1
        memDataInbound <= 16'b0000000110110000;
        instrWrite <= 1;
        newAluInput <= 1;
        #10
        instrWrite <= 0;
        #20
        newAluInput <= 0;
        aluSrc1Select <= 2'b01;
        aluSrc2Select <= 2'b00;
        #10
        if (PSR[1] == 0) $display("CMP Error");

        // CMPI 5 $0
        memDataInbound <= 16'b1011000000000101;
        instrWrite <= 1;
        newAluInput <= 1;
        #10
        instrWrite <= 0;
        #20
        newAluInput <= 0;
        aluSrc1Select <= 2'b01;
        aluSrc2Select <= 2'b01;
        #10
        if (PSR[3] == 0) $display("CMPI Error");

        // AND $0 $1
        memDataInbound <= 16'b0000000100010000;
        instrWrite <= 1;
        newAluInput <= 1;
        #10
        instrWrite <= 0;
        #20
        newAluInput <= 0;
        aluSrc1Select <= 2'b01;
        aluSrc2Select <= 2'b00;
        #10
        regWrite <= 1;
        #1000
        regWrite <= 0;

        // ANDI 15 $2
        memDataInbound <= 16'b0001001000001111;
        instrWrite <= 1;
        newAluInput <= 1;
        #10
        instrWrite <= 0;
        #20
        newAluInput <= 0;
        aluSrc1Select <= 2'b01;
        aluSrc2Select <= 2'b01;
        #10
        regWrite <= 1;
        #1000
        regWrite <= 0;

        // I'd say thats a sufficient amount of testing for computational instructions. Datapath doesn't change much for those

        // MOV $2 $5
        memDataInbound <= 16'b0000010111010010;
        instrWrite <= 1;
        newAluInput <= 1;
        #10
        instrWrite <= 0;
        #20
        newAluInput <= 0;
        aluSrc1Select <= 2'b10;
        aluSrc2Select <= 2'b00;
        #10
        regWrite <= 1;
        #1000
        regWrite <= 0;

        // MOVI 8 $8
        memDataInbound <= 16'b1101100000001000;
        instrWrite <= 1;
        newAluInput <= 1;
        #10
        instrWrite <= 0;
        #20
        newAluInput <= 0;
        aluSrc1Select <= 2'b10;
        aluSrc2Select <= 2'b01;
        #10
        regWrite <= 1;
        #1000
        regWrite <= 0;

        // LOAD $7 $8
        memDataInbound <= 16'b0100011100001000;
        instrWrite <= 1;
        newAluInput <= 1;
        #10
        instrWrite <= 0;
        #20
        newAluInput <= 0;
        #10
        if (memAddr != 16'd8) $display("Wrong load address, expected 8 but got %b", memAddr);
        writeBackSelect <= 1;
        memDataInbound <= 16'd1234; // this module hasn't been linked to ram yet so this will simulate data returning to the cpu
        regWrite <= 1;
        #1000
        regWrite <= 0;

        // STOR $2 $7
        memDataInbound <= 16'b0100001001000111;
        instrWrite <= 1;
        newAluInput <= 1;
        #10
        instrWrite <= 0;
        #20
        newAluInput <= 0;
        #10
        if (memAddr != 16'd1234) $display("Wrong store address, expected 1234 but got %b", memAddr);
        if (memWriteData != 5) $display("Wrong store data, expected 5 but got %b", memWriteData);

        // JAL $15 $7
        memDataInbound <= 16'b0100111110000111;
        instrWrite <= 1;
        newAluInput <= 1;
        #10
        instrWrite <= 0;
        #20
        newAluInput <= 0;
        #10
        dataToWriteSelect <= 1;
        regWrite <= 1;
        #1000
        regWrite <= 0;
        #10
        pcSrc <= 1;
        pcEn <= 1;
        #10
        pcEn <= 0;
    end
endmodule