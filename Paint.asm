; 1 = red
; 2 = green
; 4 = blue
; else black

; %r4 stores the selected color
; %r5 stores x position
; %r6 stores y position
; %r7 stores button data
;#define WHITE = 0
;#define RED = 1
;#define GREEN = 2
;#define BLUE = 4
;#define BLACK = 7
;
;int main() {
;    short x = RED; // r4
;    short SHORT_MAX = 0xFFFF; // r11
;
;    while(true) {
;        short loadAdd = 4088;
;        short xPos = MEM[loadAdd]; // r5
;
;        loadAdd = 4087;
;        short yPos = MEM[loadAdd]; // r6
;
;        loadAdd = 4089
;        short buttons = MEM[loadAdd]; // r7
;
;        // In color picker?
;        if (yPos < 80) { // In color picker
;            short leftMouseClickMask = 4; // r8
;            leftMouseClickMask = leftMouseClickMask & buttons;
;
;            if(leftMouseClickMask == 0) { // Left mouse not clicked
;                break;
;            }
;
;            // Left button clicked, select color
;            // Check the xPos to determine color
;            if(xPos <= 213) {
;                color = RED; // Set color to red, and loop back.
;                break;
;            }
;            else {
;                if (xPos <= 426) {
;                    color = GREEN;
;                    break;
;                }
;                else {
;                    color = BLUE;
;                    break;
;                }
;            }
;
;        }
;        else { // In Canvas
;            short colorToDraw;
;            if(buttons == 0) {
;                break;
;            }
;            else {
;                short temp = buttons; // Set temp variable to buttons
;                temp = temp & 1;      // Use mask to check if rmb is clicked
;                if(temp == 1) {       // RMB clicked;
;                    colorToDraw = WHITE; // Set color to draw as white.
;                }
;                else {
;                    temp = buttons;
;                    temp = temp & 2;
;                    if(temp == 2) { // MMB clicked;
;                        colorToDraw = BLACK;
;                    }
;                    else {
;                        colorToDraw = color;
;                    }
;
;                }
;
;                // Divide both positions by 8 to get correct buffer index
;                xPos = xPos >> 3;
;                yPos = yPos >> 3;
;
;                yPos = xPos * yPos; // yPos now equals the 0 based buffer index
;                short pixelIndex = yPos; // r10
;                pixelIndex = pixelIndex % 4; // Gets the pixel index out of 4 pixels
;                pixelIndex = pixelIndex << 2; // Get bit location of first bit in pixel
;
;                short memAddress = yPos; // MemAddress r8
;                memAddress = memAddress >> 2; MemAddress offset in memory buffer
;                memAddress = memAddress + 1024; // Adjust buffer index to point to actual buffer location in memory
;
;
;                short pixels = MEM[memAddress]; // r9 Load the 4 pixels in memory line;
;                xPos = 0xF;               // r5 Create mask to zero out pixel that we are going to set
;                xPos = xPos << pixelIndex;      // Shift mask to cover pixel to set.
;
;                xPos = xPos ^ SHORT_MAX;        // Leaves xPos as all ones except where we zeroed out the pixel.
;
;                pixels = pixels & xPos;         // Zero out pixels to be written to.
;
;                colorToDraw = colorToDraw << pixelIndex; // Shift color to draw to where it needs to be. Where we just cleared bits.
;
;                pixels = pixels | colorToDraw;
;
;                MEM[memAddress] = pixels;
;
;            }
;        }
;    }
;}


Main: 
    MOVI $1, %r4 ; Initialize the color to Red
    MOVI $65535, %r11   ; %r11 = SHORT MAX

Loop: 
    MOVI $4088, %r13 ; 4088 contains x position
    LOAD %r13, %r5
    MOVI $4087, %r13 ; 4087 contains y position
    LOAD %r13, %r6
    MOVI $4089, %r13 ; 4089 contains buttons
    LOAD %r13, %r7

    ; In color picker?
    CMPI $80, %r6 ; Check to see if we are in the canvas or control space
    BGE InCanvas

    MOVI $4, %r8    ;  Set r8 to 0b100
    AND %r7, %r8    ;  Check to see if left mouse button is clicked
    CMPI %r8, %r0   
    BEQ Loop    ; Left mouse button is not pressed, loop again

    ; Else figure out what color we are in

CheckRed:
    CMPI $213, %r5  ; Red is at xpos <= 213
    BG CheckGreen   ; Jump to green check
    MOVI $1, %r4    ; No jump, set to red
    Jump Loop       ; New color selected, loop again

CheckGreen:
    CMPI $426, %r5  ; Green is at xpos 214 <= x <= 426
    BG CheckBlue    ; Jump to blue check
    MOVI $2, %r4    ; No jump, set to red
    Jump Loop       ; New color selected, loop again

CheckBlue:
    MOVI $4, %r4    ; Default set to blue
    Jump Loop       ; New color selected, loop again

; Buffer = (400 * 640) / 8 = 32,000
; Buffer[0]     = 0x4000 = 16384
; Buffer[1]     = 0x4004 = 16388
; Buffer[2]     = 0x4008 = 16392
; Buffer[3]     = 0x400B = 16396
; Buffer[7999]  = 0x7D00 = 32000

InCanvas:
    CMP %r0, %r7    ; Check if mouse is clicked
    BEQ Loop        ; No buttons clicked, loop

SetColorWhite:
    MOV %r7, %r1            ; Copy buttons into temp
    ANDI $1, %r1            
    CMPI $1, %r1            ; Is rmb clicked?
    BNE CheckMiddleMouse
    MOVI $0, %r2            ; Color equals 0 (white)
    Jump UpdateColor

CheckMiddleMouse:
    MOV %r7, %r1            ; Copy buttons into temp
    ANDI $2, %r1   
    CMPI $2, %r1            ; Is rmb clicked?
    BNE LeftMouseClicked
    MOVI $7, %r2            ; Color equals 7 (black)
    Jump UpdateColor

LeftMouseClicked:
    MOV %r4, %r2

UpdateColor:
    RSHI $3, %r5    ; Divide position by 8 to get buffer address
    RSHI $3, %r6    ; Divide position by 8 to get buffer address
    MUL %r5, %r6    ; Multiple to get buffer address in r6
    MOV %r6, %r10   ; Store buffer offset
    MODI $4, %r10   ; Get pixel location in memory address
    LSHI $2, %r10   ; Get bit location of first bit in pixel

    MOV %r6, %r8    ; Create temp variable in $r8
    RSHI $2, %r8    ; Divide temp by 4 to get offset
    ADDI $1024, %r8 ; Add 1024 to get into MemLocation
                    
    LOAD %r8, %r9       ; Load pixel from buf location
    MOVI $15, %r5       ; r5 = 0b1111
    LSH %r10, %r5       ; shift 1111 to 0 out r11
    XOR %r11, %r5       ; %r5 = 1's where the pixel is not
    AND %r5, %r9        ; 0 out pixels to be written to 
    LSH %r10, %r2       ; shift pixel value to where it needs to be
    OR %r2, %r9         ; r9 pixel color in position
    STORE %r8, %r9      ; pixel written

    Jump Loop
