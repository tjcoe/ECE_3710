MOVI $1 %r4 
MOV %r0 %r11 
SUBI $1 %r11 
MOVI $5 %r3 
MOVI $53 %r14 
MOVI $1 %r13 
LSHI $12 %r13 
SUBI $7 %r13 
MOV %r13 %r15 
LSHI $4 %r13 
LOAD %r13 %r7 
SUBI $1 %r15 
MOV %r15 %r13 
LSHI $4 %r13 
LOAD %r13 %r5 
SUBI $1 %r15 
MOV %r15 %r13 
LSHI $4 %r13 
LOAD %r13 %r6 
CMPI $80 %r6 
BGE $18 
MOVI $4 %r8 
AND %r7 %r8 
CMP %r8 %r0 
JEQ %r3 
MOVI $127 %r1 
ADDI $86 %r1 
CMP %r1 %r5 
BGT $3 
MOVI $1 %r4 
JUC %r3 
LSHI $1 %r1 
CMP %r1 %r5 
BGT $3 
MOVI $2 %r4 
JUC %r3 
MOVI $4 %r4 
JUC %r3 
CMP %r0 %r7 
JUC %r3 
MOV %r7 %r1 
ANDI $1 %r1 
CMPI $1 %r1 
BNE $3 
MOVI $0 %r2 
JUC %r14 
MOV %r7 %r1 
ANDI $2 %r1 
CMPI $2 %r1 
BNE $3 
MOVI $7 %r2 
JUC %r14 
MOV %r4 %r2 
RSHI $3 %r5 
SUBI $80 %r6 
RSHI $3 %r6 
MOVI $80 %r1 
MUL %r1 %r6 
ADD %r5 %r6 
MOV %r6 %r10 
MODI $4 %r10 
LSHI $2 %r10 
MOV %r6 %r8 
RSHI $2 %r8 
MOVI $1 %r12 
LSHI $10 %r12 
ADD %r12 %r8 
LOAD %r8 %r9 
MOVI $15 %r5 
LSH %r10 %r5 
XOR %r11 %r5 
AND %r5 %r9 
LSH %r10 %r2 
OR %r2 %r9 
STOR %r8 %r9 
JUC %r3 
