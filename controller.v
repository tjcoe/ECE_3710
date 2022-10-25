module controller (input clk, reset, zero,
                   input [3:0] op, opExt, cond,
                   output reg memWrite, 
                   output pcEn, 
                   output reg regWrite, instrWrite,
                   output reg [1:0] pcSrc, aluSrc1Sel, aluSrc2Sel);

    // state names
    parameter FETCH  = 0;
    parameter DECODE = 0;

    // instructions with immediates (no opExt)
    parameter ADDI  = 4'b0101;
    parameter SUBI  = 4'b1001;
    parameter CMPI  = 4'b1011;
    parameter ANDI  = 4'b0001;
    parameter ORI   = 4'b0010;
    parameter XORI  = 4'b0011;
    parameter MOVI  = 4'b1101;
    parameter LUI   = 4'b1111;
    parameter Bcond = 4'b1100; // see cond values

    parameter SIMPLE_NON_IMM = 4'b0000;
    // op exts for op code = 0000
    parameter ADD  = 4'b0101;
    parameter SUB  = 4'b1001;
    parameter CMP  = 4'b1011;
    parameter AND  = 4'b0001;
    parameter OR   = 4'b0010;
    parameter XOR  = 4'b0011;
    parameter MOV  = 4'b1101;

    parameter LSH_INSTRS = 4'b1000; // if opExt is 0100 then LSH otherwise it is LSHI

    parameter MEM_INSTRS = 4'b0100;
    // op exts for op code = 0100
    parameter LOAD  = 4'b0000;
    parameter STOR  = 4'b0100;
    parameter JAL   = 4'b1000;
    parameter Jcond = 4'b1100; // see cond values

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
    // default for 1111: never jump (continue to next instr?)

    reg [X:0] nextState, state;
    reg       pcWrite, pcWriteCond;

    always @(posedge clk)
        if (~reset) state <= FETCH;
        else state <= nextState;
    
    always @(*) begin
        case(state)
            FETCH:  nextState <= DECODE;
            DECODE: case(op)
                        SIMPLE_NON_IMM:
                            case(opExt)
                                ADD: // load regs, add, writeback
                                SUB: // load regs, sub, writeback
                                CMP: // load regs, sub (set flags)
                                AND: // load regs, and, writeback
                                OR:  // load regs, or, writeback
                                XOR: // load regs, xor, writeback
                                MOV: // load src, add 0, write to dest
                            endcase
                        LSH_INSTRS:
                            if (opExt == 4'b0100) // LSH - load regs, alu shift, writeback
                            else // LSHI - load reg, alu shift by imm, writeback
                        MEM_INSTRS:
                            case(opExt)
                                LOAD: // load reg w/ addr, read mem, select mux to writeback
                                STOR: // load data to write, write to mem, ???writeback???
                                JAL:
                                Jcond:
                                    case(cond)
                                        EQ:
                                        NE:
                                        GE:
                                        CS:
                                        CC:
                                        HI:
                                        LS:
                                        LO:
                                        HS:
                                        GT:
                                        LE:
                                        FS:
                                        FC:
                                        LT:
                                        UC:
                                        default: // never jump, just fetch next inst?
                                    endcase
                            endcase
                        ADDI: // load reg, add, writeback
                        SUBI: // load reg, sub, writeback
                        CMPI: // load reg, sub (set flags)
                        ANDI: // load reg, and, writeback
                        ORI:  // load reg, or, writeback
                        XORI: // load reg, xor, writeback
                        MOVI: // add imm + 0, write to dest
                        LUI:  // load reg, alu shift, writeback
                        Bcond:
                            case(cond)
                                EQ:
                                NE:
                                GE:
                                CS:
                                CC:
                                HI:
                                LS:
                                LO:
                                HS:
                                GT:
                                LE:
                                FS:
                                FC:
                                LT:
                                UC:
                                default: // never jump, just fetch next inst?
                            endcase
                    endcase
            default: nextState <= FETCH;
        endcase
    end

    always @(*) begin
        instrWrite <= 0;
        pcSrc <= 2'b00; pcEn <= 0; pcWriteCond <= 0;
        memWrite <= 0; regWrite <= 0;
        aluSrc1Sel <= 2'b00; aluSrc2Sel <= 2'b00;
        case(state)
            FETCH:
                begin
                    instrWrite <= 1;
                    pcEn <= 1;
                end
        endcase
    end
    assign pcEn = pcEn | (pcWriteCond & zero);
endmodule