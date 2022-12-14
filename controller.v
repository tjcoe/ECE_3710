module controller (input clk, reset, zero,
                   input [3:0] op, opExt, cond,
                   input [7:0] PSR,
                   output reg memWrite, 
                   output pcEn,
                   output reg writeBackSelect, dataToWriteSelect, newAluInput, psrRegEn, sendPcAddr,
                   output reg regWrite, instrWrite,
                   output reg [1:0] aluSrc1Sel, aluSrc2Sel, pcSrc);

    // Every state that begins with a 001/010/011/100 is for internal use
    // States beginning with 00 are associated with their corresponding encodings
    // E.G. 010010 is just a random variable assigned to basic loading instructions
    // however 000010 corresponds to the ori instruction
    wire [6:0] op5Bit, opExt5Bit;
    assign op5Bit    = {3'b0,op};
    assign opExt5Bit = {3'b0,opExt};

    // state names
    parameter FETCH           = 7'b0010000;
    parameter DECODE          = 7'b0010001;
    parameter BASIC_LOAD_REGS = 7'b0010010; // basic refers to non-immediate add, sub, and, or, xor
    parameter IMM_LOAD_REGS   = 7'b0010011; // this corresponds to the immediate versions of the basic instrs
    parameter BASIC_ALU_EX    = 7'b0010100;
    parameter IMM_ALU_EX      = 7'b0010101;
    parameter WRITEBACK       = 7'b0010110;
    parameter CMP_LOAD_REG    = 7'b0010111;
    parameter CMPI_LOAD_REG   = 7'b0011000;
    parameter CMP_ALU_EX      = 7'b0011001;
    parameter CMPI_ALU_EX     = 7'b0011010;
    parameter MOV_LOAD_REG    = 7'b0011011;
    parameter MOVI_LOAD_REG   = 7'b0011100;
    parameter MOV_ALU_EX      = 7'b0011101;
    parameter MOVI_ALU_EX     = 7'b0011110;
    parameter LOAD_REG        = 7'b0011111;
    parameter STOR_REG        = 7'b0100000;
    parameter MEM_READ        = 7'b0100001;
    parameter MEM_WRITE       = 7'b0100010;
    parameter LOAD_WB         = 7'b0100011;
    parameter JAL_REG         = 7'b0100100;
    parameter JAL_STORE_PC    = 7'b0100101;
    parameter JAL_NEW_PC      = 7'b0100110;
    parameter PC_INCR         = 7'b0100111;
    parameter PC_INCR2        = 7'b0101000;
    parameter PC_INCR3        = 7'b0101001;
    parameter MEM_READ2       = 7'b1001000;
    parameter MEM_READ3       = 7'b1001001;

    parameter JCOND_EQ = 7'b0101010;
    parameter JCOND_NE = 7'b0101011;
    parameter JCOND_GE = 7'b0101100;
    parameter JCOND_CS = 7'b0101101;
    parameter JCOND_CC = 7'b0101110;
    parameter JCOND_HI = 7'b0101111;
    parameter JCOND_LS = 7'b0110000;
    parameter JCOND_LO = 7'b0110001;
    parameter JCOND_HS = 7'b0110010;
    parameter JCOND_GT = 7'b0110011;
    parameter JCOND_LE = 7'b0110100;
    parameter JCOND_FS = 7'b0110101;
    parameter JCOND_FC = 7'b0110110;
    parameter JCOND_LT = 7'b0110111;
    parameter JCOND_UC = 7'b0111000;

    parameter BCOND_EQ = 7'b0111001;
    parameter BCOND_NE = 7'b0111010;
    parameter BCOND_GE = 7'b0111011;
    parameter BCOND_CS = 7'b0111100;
    parameter BCOND_CC = 7'b0111101;
    parameter BCOND_HI = 7'b0111110;
    parameter BCOND_LS = 7'b0111111;
    parameter BCOND_LO = 7'b1000000;
    parameter BCOND_HS = 7'b1000001;
    parameter BCOND_GT = 7'b1000010;
    parameter BCOND_LE = 7'b1000011;
    parameter BCOND_FS = 7'b1000100;
    parameter BCOND_FC = 7'b1000101;
    parameter BCOND_LT = 7'b1000110;
    parameter BCOND_UC = 7'b1000111;

    // instructions with immediates (no opExt)
    parameter ADDI  = 7'b0000101;
    parameter SUBI  = 7'b0001001;
    parameter CMPI  = 7'b0001011;
    parameter ANDI  = 7'b0000001;
    parameter ORI   = 7'b0000010;
    parameter XORI  = 7'b0000011;
    parameter MOVI  = 7'b0001101;
    parameter LUI   = 7'b0001111;
    parameter Bcond = 7'b0001100; // see cond values
    parameter MODI  = 7'b0000110;

    parameter SIMPLE_NON_IMM = 7'b0;
    // op exts for op code = 0000
    parameter ADD  = 7'b0000101;
    parameter MUL  = 7'b0001110;
    parameter SUB  = 7'b0001001;
    parameter CMP  = 7'b0001011;
    parameter AND  = 7'b0000001;
    parameter OR   = 7'b0000010;
    parameter XOR  = 7'b0000011;
    parameter MOV  = 7'b0001101;

    parameter LSH_INSTRS = 7'b0001000; // if opExt is 0100 then LSH otherwise it is LSHI

    parameter MEM_INSTRS = 7'b0000100;
    // op exts for op code = 0100
    parameter LOAD  = 7'b0000000;
    parameter STOR  = 7'b0000100;
    parameter JAL   = 7'b0001000;
    parameter Jcond = 7'b0001100; // see cond values

    // Bcond/Jcond "cond" codes
    parameter EQ = 4'b0000;
    parameter NE = 4'b0001;
    parameter GE = 4'b1101;
    parameter CS = 4'b0010;
    parameter CC = 4'b0011;
    parameter HI = 4'b0100;
    parameter LS = 4'b0101;
    parameter LO = 4'b1010;
    parameter HS = 4'b1011;
    parameter GT = 4'b0110;
    parameter LE = 4'b0111;
    parameter FS = 4'b1000;
    parameter FC = 4'b1001;
    parameter LT = 4'b1100;
    parameter UC = 4'b1110;
    // default for 001111: never jump (continue to next instr?)

    reg [6:0] nextState, state;
    reg       pcWrite, pcWriteCond;
    
    always @(posedge clk)
        if (~reset) state <= FETCH;
        else state <= nextState;
    
    always @(*) begin
        case(state)
            FETCH:  nextState <= DECODE;
            DECODE: case(op5Bit)
                        SIMPLE_NON_IMM:
                            case(opExt5Bit)
                                ADD, SUB, AND, OR, XOR, MUL: nextState <= BASIC_LOAD_REGS; // load regs, alu, writeback
                                CMP: nextState <= CMP_LOAD_REG;// load regs, sub (set flags)
                                MOV: nextState <= MOV_LOAD_REG;// load src, add 0, write to dest
                                default: nextState <= PC_INCR;
                            endcase
                        LSH_INSTRS:
                            if (opExt5Bit == 5'b00100) nextState <= BASIC_LOAD_REGS; // LSH - load regs, alu shift, writeback
                            else nextState <= IMM_LOAD_REGS; // LSHI - load reg, alu shift by imm, writeback
                        MEM_INSTRS:
                            case(opExt5Bit)
                                LOAD: nextState <= LOAD_REG; // load reg w/ addr, read mem, select mux to writeback
                                STOR: nextState <= STOR_REG; // load data to write, write to mem, ???writeback???
                                JAL:  nextState <= JAL_REG; // load addr from reg, set as next addr for pc, write next instr to reg
                                Jcond: // absolute 
                                    case(cond)
                                        EQ: nextState <= JCOND_EQ;
                                        NE: nextState <= JCOND_NE;
                                        GE: nextState <= JCOND_GE;
                                        CS: nextState <= JCOND_CS;
                                        CC: nextState <= JCOND_CC;
                                        HI: nextState <= JCOND_HI;
                                        LS: nextState <= JCOND_LS;
                                        LO: nextState <= JCOND_LO;
                                        HS: nextState <= JCOND_HS;
                                        GT: nextState <= JCOND_GT;
                                        LE: nextState <= JCOND_LE;
                                        FS: nextState <= JCOND_FS;
                                        FC: nextState <= JCOND_FC;
                                        LT: nextState <= JCOND_LT;
                                        UC: nextState <= JCOND_UC;
                                        default: nextState <= PC_INCR; // never jump, just fetch next inst?
                                    endcase
                                default: nextState <= PC_INCR;
                            endcase
                        ADDI, SUBI, ANDI, ORI, XORI, LUI, MODI: nextState <= IMM_LOAD_REGS; // load reg, alu, writeback
                        CMPI: nextState <= CMPI_LOAD_REG;// load reg, sub (set flags)
                        MOVI: nextState <= MOVI_LOAD_REG;// add imm + 0, write to dest
                        Bcond: // relative
                            case(cond)
                                EQ: nextState <= BCOND_EQ;
                                NE: nextState <= BCOND_NE;
                                GE: nextState <= BCOND_GE;
                                CS: nextState <= BCOND_CS;
                                CC: nextState <= BCOND_CC;
                                HI: nextState <= BCOND_HI;
                                LS: nextState <= BCOND_LS;
                                LO: nextState <= BCOND_LO;
                                HS: nextState <= BCOND_HS;
                                GT: nextState <= BCOND_GT;
                                LE: nextState <= BCOND_LE;
                                FS: nextState <= BCOND_FS;
                                FC: nextState <= BCOND_FC;
                                LT: nextState <= BCOND_LT;
                                UC: nextState <= BCOND_UC;
                                default: nextState <= PC_INCR; // never jump, just fetch next inst?
                            endcase
                        default: nextState <= PC_INCR;
                    endcase
            BASIC_LOAD_REGS: nextState <= BASIC_ALU_EX;
            IMM_LOAD_REGS:   nextState <= IMM_ALU_EX;
            BASIC_ALU_EX:    nextState <= WRITEBACK;
            IMM_ALU_EX:      nextState <= WRITEBACK;
            WRITEBACK:       nextState <= PC_INCR;
            CMP_LOAD_REG:    nextState <= CMP_ALU_EX;
            CMPI_LOAD_REG:   nextState <= CMPI_ALU_EX;
            CMP_ALU_EX:      nextState <= PC_INCR;
            CMPI_ALU_EX:     nextState <= PC_INCR;
            MOV_LOAD_REG:    nextState <= MOV_ALU_EX;
            MOVI_LOAD_REG:   nextState <= MOVI_ALU_EX;
            MOV_ALU_EX:      nextState <= WRITEBACK;
            MOVI_ALU_EX:     nextState <= WRITEBACK;
            LOAD_REG:        nextState <= MEM_READ;
            STOR_REG:        nextState <= MEM_WRITE;
            MEM_READ:        nextState <= MEM_READ2;
            MEM_WRITE:       nextState <= PC_INCR;
            MEM_READ2:       nextState <= MEM_READ3;
            MEM_READ3:       nextState <= LOAD_WB;
            LOAD_WB:         nextState <= PC_INCR;
            JAL_REG:         nextState <= JAL_STORE_PC;
            JAL_STORE_PC:    nextState <= JAL_NEW_PC;
            JAL_NEW_PC:      nextState <= PC_INCR;
            PC_INCR:         nextState <= PC_INCR2;
            PC_INCR2:        nextState <= PC_INCR3;
            PC_INCR3:        nextState <= FETCH;
            JCOND_EQ, JCOND_NE, JCOND_GE, JCOND_CS, JCOND_CC, JCOND_HI, JCOND_LS, JCOND_LO, JCOND_HS, JCOND_GT, JCOND_LE, JCOND_FS, JCOND_FC, JCOND_LT, JCOND_UC: nextState <= PC_INCR2;
            BCOND_EQ, BCOND_NE, BCOND_GE, BCOND_CS, BCOND_CC, BCOND_HI, BCOND_LS, BCOND_LO, BCOND_HS, BCOND_GT, BCOND_LE, BCOND_FS, BCOND_FC, BCOND_LT, BCOND_UC: nextState <= PC_INCR2;
            default:         nextState <= PC_INCR;
        endcase
    end

    always @(*) begin
        sendPcAddr <= 0;
        pcSrc <= 2'b00; pcWriteCond <= 0; pcWrite <= 0;
        instrWrite <= 0;
        newAluInput <= 0; psrRegEn <= 0;
        aluSrc1Sel <= 2'b00; aluSrc2Sel <= 2'b00;
        writeBackSelect <= 0; dataToWriteSelect <= 0;
        memWrite <= 0; regWrite <= 0;
        case(state)
            FETCH:
                begin
                    $display("FETCH");
                    instrWrite <= 1;
                    sendPcAddr <= 1;
                end
            DECODE:
                begin
                    $display("DECODE");
                    // nothing to do?
                end
            BASIC_LOAD_REGS:
                begin
                    $display("BASIC_LOAD_REGS");
                    newAluInput <= 1;
                end
            IMM_LOAD_REGS:
                begin
                    $display("IMM_LOAD_REGS");
                    newAluInput <= 1;
                end
            BASIC_ALU_EX:
                begin
                    $display("BASIC_ALU_EX");
                    aluSrc1Sel <= 2'b01;
                end
            IMM_ALU_EX:
                begin
                    $display("IMM_ALU_EX");
                    aluSrc1Sel <= 2'b01;
                    aluSrc2Sel <= 2'b01;
                end
            WRITEBACK:
                begin
                    $display("WRITEBACK");
                    regWrite <= 1;
                end
            CMP_LOAD_REG:
                begin
                    $display("CMP_LOAD_REG");
                    newAluInput <= 1;
                end
            CMPI_LOAD_REG:
                begin
                    $display("CMPI_LOAD_REG");
                    newAluInput <= 1;
                end
            CMP_ALU_EX:
                begin
                    $display("CMP_ALU_EX");
                    aluSrc1Sel <= 2'b01;
                    psrRegEn <= 1;
                end
            CMPI_ALU_EX:
                begin
                    $display("CMPI_ALU_EX");
                    aluSrc1Sel <= 2'b01;
                    aluSrc2Sel <= 2'b01;
                    psrRegEn <= 1;
                end
            MOV_LOAD_REG:
                begin
                    $display("MOV_LOAD_REG");
                    newAluInput <= 1;
                end
            MOVI_LOAD_REG:
                begin
                    $display("MOVI_LOAD_REG");
                    newAluInput <= 1;
                end
            MOV_ALU_EX:
                begin
                    $display("MOV_ALU_EX");
                    aluSrc1Sel <= 2'b10;
                end
            MOVI_ALU_EX: // should flags be set or not
                begin
                    $display("MOVI_ALU_EX");
                    aluSrc1Sel <= 2'b10;
                    aluSrc2Sel <= 2'b01;
                end
            LOAD_REG:
                begin
                    $display("LOAD_REG");
                    newAluInput <= 1;
                end
            STOR_REG:
                begin
                    $display("STOR_REG");
                    newAluInput <= 1;
                end
            MEM_READ:
                begin
                    $display("MEM_READ");
                    // nothing to do?
                end
            MEM_READ2:
                begin
                    $display("MEM_READ2");
                    // nothing to do?
                end
            MEM_READ3:
                begin
                    $display("MEM_READ3");
                    writeBackSelect <= 1;
                end
            MEM_WRITE:
                begin
                    $display("MEM_WRITE");
                    memWrite <= 1;
                end
            LOAD_WB:
                begin
                    $display("LOAD_WB");
                    regWrite <= 1;
                end
            JAL_REG:
                begin
                    $display("JAL_REG");
                    newAluInput <= 1;
                end
            JAL_STORE_PC:
                begin
                    $display("JAL_STORE_PC");
                    dataToWriteSelect <= 1;
                    regWrite <= 1;
                end
            JAL_NEW_PC:
                begin
                    $display("JAL_NEW_PC");
                    pcSrc <= 2'b01;
                    pcWrite <= 1;
                end
            PC_INCR:
                begin
                    $display("PC_INCR");
                    pcWrite <= 1;
                    aluSrc1Sel <= 2'b01;
                end
            PC_INCR2:
                begin
                    $display("PC_INCR2"); // need to kill cycles
                end
            PC_INCR3:
                begin
                    $display("PC_INCR3"); // kill cycle
                    sendPcAddr <= 1;
                end
            JCOND_EQ:
                begin
                    $display("JCOND_EQ");
                    if (PSR[1] == 1) pcSrc <= 2'b01;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            JCOND_NE:
                begin
                    $display("JCOND_NE");
                    if (PSR[1] == 0) pcSrc <= 2'b01;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            JCOND_GE:
                begin
                    $display("JCOND_GE");
                    if (PSR[1] == 1 || PSR[0] == 1) pcSrc <= 2'b01;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            JCOND_CS:
                begin
                    $display("JCOND_CS");
                    if (PSR[4] == 1) pcSrc <= 2'b01;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            JCOND_CC:
                begin
                    $display("JCOND_CC");
                    if (PSR[4] == 0) pcSrc <= 2'b01;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            JCOND_HI:
                begin
                    $display("JCOND_HI");
                    if (PSR[3] == 1) pcSrc <= 2'b01;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            JCOND_LS:
                begin
                    $display("JCOND_LS");
                    if (PSR[3] == 0) pcSrc <= 2'b01;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            JCOND_LO:
                begin
                    $display("JCOND_LO");
                    if (PSR[3] == 0 && PSR[1] == 0) pcSrc <= 2'b01;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            JCOND_HS:
                begin
                    $display("JCOND_HS");
                    if (PSR[3] == 1 || PSR[1] == 1) pcSrc <= 2'b01;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            JCOND_GT:
                begin
                    $display("JCOND_GT");
                    if (PSR[0] == 1) pcSrc <= 2'b01;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            JCOND_LE:
                begin
                    $display("JCOND_LE");
                    if (PSR[0] == 0) pcSrc <= 2'b01;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            JCOND_FS:
                begin
                    $display("JCOND_FS");
                    if (PSR[2] == 1) pcSrc <= 2'b01;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            JCOND_FC:
                begin
                    $display("JCOND_FC");
                    if (PSR[2] == 0) pcSrc <= 2'b01;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            JCOND_LT:
                begin
                    $display("JCOND_LT");
                    if (PSR[0] == 0 && PSR[1] == 0) pcSrc <= 2'b01;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            JCOND_UC:
                begin
                    $display("JCOND_UC");
                    pcSrc <= 2'b01;
                    pcWrite <= 1;
                end
            BCOND_EQ:
                begin
                    $display("BCOND_EQ");
                    if (PSR[1] == 1) pcSrc <= 2'b10;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            BCOND_NE:
                begin
                    $display("BCOND_NE");
                    if (PSR[1] == 0) pcSrc <= 2'b10;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            BCOND_GE:
                begin
                    $display("BCOND_GE");
                    if (PSR[1] == 1 || PSR[0] == 1) pcSrc <= 2'b10;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            BCOND_CS:
                begin
                    $display("BCOND_CS");
                    if (PSR[4] == 1) pcSrc <= 2'b10;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            BCOND_CC:
                begin
                    $display("BCOND_CC");
                    if (PSR[4] == 0) pcSrc <= 2'b10;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            BCOND_HI:
                begin
                    $display("BCOND_HI");
                    if (PSR[3] == 1) pcSrc <= 2'b10;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            BCOND_LS:
                begin
                    $display("BCOND_LS");
                    if (PSR[3] == 0) pcSrc <= 2'b10;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            BCOND_LO:
                begin
                    $display("BCOND_LO");
                    if (PSR[3] == 0 && PSR[1] == 0) pcSrc <= 2'b10;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            BCOND_HS:
                begin
                    $display("BCOND_HS");
                    if (PSR[3] == 1 || PSR[1] == 1) pcSrc <= 2'b10;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            BCOND_GT:
                begin
                    $display("BCOND_GT");
                    if (PSR[1] == 1) pcSrc <= 2'b10;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            BCOND_LE:
                begin
                    $display("BCOND_LE");
                    if (PSR[0] == 0) pcSrc <= 2'b10;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            BCOND_FS:
                begin
                    $display("BCOND_FS");
                    if (PSR[2] == 1) pcSrc <= 2'b10;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            BCOND_FC:
                begin
                    $display("BCOND_FC");
                    if (PSR[2] == 0) pcSrc <= 2'b10;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            BCOND_LT:
                begin
                    $display("BCOND_LT");
                    if (PSR[0] == 0 && PSR[1] == 0) pcSrc <= 2'b10;
                    else pcSrc <= 2'b0;
                    pcWrite <= 1;
                end
            BCOND_UC:
                begin
                    $display("BCOND_UC");
                    pcSrc <= 2'b10;
                    pcWrite <= 1;
                end
            default:
                begin
                    $display("DEFAULT");
                end
        endcase
    end
    assign pcEn = pcWrite | (pcWriteCond & zero);
endmodule
