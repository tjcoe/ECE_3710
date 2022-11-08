module controller (input clk, reset, zero,
                   input [3:0] op, opExt, cond,
                   output reg memWrite, 
                   output pcEn,
                   output reg writeBackSelect, dataToWriteSelect, pcSrc, newAluInput,
                   output reg regWrite, instrWrite,
                   output reg [1:0] aluSrc1Sel, aluSrc2Sel);

    // Every state that begins with a 01/10/11 is for internal use
    // States beginning with 00 are associated with their corresponding encodings
    // E.G. 010010 is just a random variable assigned to basic loading instructions
    // however 000010 corresponds to the ori instruction
    wire [5:0] op5Bit, opExt5Bit;
    assign op5Bit = {2'b0,op};
    assign opExt5Bit = {2'b0,opExt};

    // state names
    parameter FETCH           = 6'b010000;
    parameter DECODE          = 6'b010001;
    parameter BASIC_LOAD_REGS = 6'b010010; // basic refers to non-immediate add, sub, and, or, xor
    parameter IMM_LOAD_REGS   = 6'b010011; // this corresponds to the immediate versions of the basic instrs
    parameter BASIC_ALU_EX    = 6'b010100;
    parameter IMM_ALU_EX      = 6'b010101;
    parameter WRITEBACK       = 6'b010110;
    parameter CMP_LOAD_REG    = 6'b010111;
    parameter CMPI_LOAD_REG   = 6'b011000;
    parameter CMP_ALU_EX      = 6'b011001;
    parameter CMPI_ALU_EX     = 6'b011010;
    parameter MOV_LOAD_REG    = 6'b011011;
    parameter MOVI_LOAD_REG   = 6'b011100;
    parameter MOV_ALU_EX      = 6'b011101;
    parameter MOVI_ALU_EX     = 6'b011110;
    parameter LOAD_REG        = 6'b011111;
    parameter STOR_REG        = 6'b100000;
    parameter MEM_READ        = 6'b100001;
    parameter MEM_WRITE       = 6'b100010;
    parameter LOAD_WB         = 6'b100011;
    parameter JAL_REG         = 6'b100100;
    parameter JAL_STORE_PC    = 6'b100101;
    parameter JAL_NEW_PC      = 6'b100110;
    // need to add a PC_INCR state but ALU needs to be able to preform add without setting flags

    // instructions with immediates (no opExt)
    parameter ADDI  = 6'b000101;
    parameter SUBI  = 6'b001001;
    parameter CMPI  = 6'b001011;
    parameter ANDI  = 6'b000001;
    parameter ORI   = 6'b000010;
    parameter XORI  = 6'b000011;
    parameter MOVI  = 6'b001101;
    parameter LUI   = 6'b001111;
    parameter Bcond = 6'b001100; // see cond values

    parameter SIMPLE_NON_IMM = 5'b00000;
    // op exts for op code = 0000
    parameter ADD  = 6'b000101;
    parameter SUB  = 6'b001001;
    parameter CMP  = 6'b001011;
    parameter AND  = 6'b000001;
    parameter OR   = 6'b000010;
    parameter XOR  = 6'b000011;
    parameter MOV  = 6'b001101;

    parameter LSH_INSTRS = 6'b001000; // if opExt is 0100 then LSH otherwise it is LSHI

    parameter MEM_INSTRS = 6'b000100;
    // op exts for op code = 0100
    parameter LOAD  = 6'b000000;
    parameter STOR  = 6'b000100;
    parameter JAL   = 6'b001000;
    parameter Jcond = 6'b001100; // see cond values

    // Bcond/Jcond "cond" codes
    parameter EQ = 6'b000000;
    parameter NE = 6'b000001;
    parameter GE = 6'b001101;
    parameter CS = 6'b000010;
    parameter CC = 6'b000011;
    parameter HI = 6'b000100;
    parameter LS = 6'b000101;
    parameter LO = 6'b001010;
    parameter HS = 6'b001011;
    parameter GT = 6'b000110;
    parameter LE = 6'b000111;
    parameter FS = 6'b001000;
    parameter FC = 6'b001001;
    parameter LT = 6'b001100;
    parameter UC = 6'b001110;
    // default for 001111: never jump (continue to next instr?)

    reg [5:0] nextState, state;
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
                                ADD, SUB, AND, OR, XOR: nextState <= BASIC_LOAD_REGS; // load regs, alu, writeback
                                CMP: nextState <= CMP_LOAD_REG;// load regs, sub (set flags)
                                MOV: nextState <= MOV_LOAD_REG;// load src, add 0, write to dest
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
                                        EQ: nextState <= FETCH;
                                        NE: nextState <= FETCH;
                                        GE: nextState <= FETCH;
                                        CS: nextState <= FETCH;
                                        CC: nextState <= FETCH;
                                        HI: nextState <= FETCH;
                                        LS: nextState <= FETCH;
                                        LO: nextState <= FETCH;
                                        HS: nextState <= FETCH;
                                        GT: nextState <= FETCH;
                                        LE: nextState <= FETCH;
                                        FS: nextState <= FETCH;
                                        FC: nextState <= FETCH;
                                        LT: nextState <= FETCH;
                                        UC: nextState <= FETCH;
                                        default: nextState <= FETCH; // never jump, just fetch next inst?
                                    endcase
                            endcase
                        ADDI, SUBI, ANDI, ORI, XORI, LUI: nextState <= IMM_LOAD_REGS; // load reg, alu, writeback
                        CMPI: nextState <= CMPI_LOAD_REG;// load reg, sub (set flags)
                        MOVI: nextState <= MOVI_LOAD_REG;// add imm + 0, write to dest
                        Bcond: // relative
                            case(cond)
                                EQ: nextState <= FETCH;
                                NE: nextState <= FETCH;
                                GE: nextState <= FETCH;
                                CS: nextState <= FETCH;
                                CC: nextState <= FETCH;
                                HI: nextState <= FETCH;
                                LS: nextState <= FETCH;
                                LO: nextState <= FETCH;
                                HS: nextState <= FETCH;
                                GT: nextState <= FETCH;
                                LE: nextState <= FETCH;
                                FS: nextState <= FETCH;
                                FC: nextState <= FETCH;
                                LT: nextState <= FETCH;
                                UC: nextState <= FETCH;
                                default: nextState <= FETCH; // never jump, just fetch next inst?
                            endcase
                    endcase
            BASIC_LOAD_REGS: nextState <= BASIC_ALU_EX;
            IMM_LOAD_REGS:   nextState <= IMM_ALU_EX;
            BASIC_ALU_EX:    nextState <= WRITEBACK;
            IMM_ALU_EX:      nextState <= WRITEBACK;
            WRITEBACK:       nextState <= FETCH;
            CMP_LOAD_REG:    nextState <= CMP_ALU_EX;
            CMPI_LOAD_REG:   nextState <= CMPI_ALU_EX;
            CMP_ALU_EX:      nextState <= FETCH;
            CMPI_ALU_EX:     nextState <= FETCH;
            MOV_LOAD_REG:    nextState <= MOV_ALU_EX;
            MOVI_LOAD_REG:   nextState <= MOVI_ALU_EX;
            MOV_ALU_EX:      nextState <= WRITEBACK;
            MOVI_ALU_EX:     nextState <= WRITEBACK;
            LOAD_REG:        nextState <= MEM_READ;
            STOR_REG:        nextState <= MEM_WRITE;
            MEM_READ:        nextState <= LOAD_WB;
            MEM_WRITE:       nextState <= FETCH;
            LOAD_WB:         nextState <= FETCH;
            JAL_REG:         nextState <= JAL_STORE_PC;
            JAL_STORE_PC:    nextState <= JAL_NEW_PC;
            JAL_NEW_PC:      nextState <= FETCH;
            default:         nextState <= FETCH;
        endcase
    end

    always @(*) begin
        pcSrc <= 2'b00; pcWriteCond <= 0;
        instrWrite <= 0;
        newAluInput <= 0;
        aluSrc1Sel <= 2'b00; aluSrc2Sel <= 2'b00;
        writeBackSelect <= 0; dataToWriteSelect <= 0;
        memWrite <= 0; regWrite <= 0;
        case(state)
            FETCH:
                begin
                    $display("FETCH");
                    instrWrite <= 1;
                end
            DECODE:
                begin
                    $display("DECODE");
                    // nothing to do?
                end
            BASIC_LOAD_REGS:
                begin
                    newAluInput <= 1;
                end
            IMM_LOAD_REGS:
                begin
                    $display("IMM_LOAD_REGS");
                    newAluInput <= 1;
                end
            BASIC_ALU_EX:
                begin
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
                    newAluInput <= 1;
                end
            CMPI_LOAD_REG:
                begin
                    newAluInput <= 1;
                end
            CMP_ALU_EX:
                begin
                    aluSrc1Sel <= 2'b01;
                end
            CMPI_ALU_EX:
                begin
                    aluSrc1Sel <= 2'b01;
                    aluSrc2Sel <= 2'b01;
                end
            MOV_LOAD_REG:
                begin
                    newAluInput <= 1;
                end
            MOVI_LOAD_REG:
                begin
                    newAluInput <= 1;
                end
            MOV_ALU_EX:
                begin
                    aluSrc1Sel <= 2'b10;
                end
            MOVI_ALU_EX: // should flags be set or not
                begin
                    aluSrc1Sel <= 2'b10;
                    aluSrc2Sel <= 2'b01;
                end
            LOAD_REG:
                begin
                    newAluInput <= 1;
                end
            STOR_REG:
                begin
                    newAluInput <= 1;
                end
            MEM_READ:
                begin
                    // nothing to do?
                end
            MEM_WRITE:
                begin
                    // nothing to do?
                end
            LOAD_WB:
                begin
                    writeBackSelect <= 1;
                    regWrite <= 1;
                end
            JAL_REG:
                begin
                    newAluInput <= 1;
                end
            JAL_STORE_PC:
                begin
                    dataToWriteSelect <= 1;
                    regWrite <= 1;
                end
            JAL_NEW_PC:
                begin
                    pcSrc <= 1;
                    pcWrite <= 1;
                end
        endcase
    end
    assign pcEn = pcWrite | (pcWriteCond & zero);
endmodule