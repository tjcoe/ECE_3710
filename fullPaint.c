int xLoc = 0;
int yLoc = 0; 
int left = 0; // Is a 1 bit value
int right = 0; // Is a 1 bit value
int middle = 0; // Is a 1 bit value
int selectedColor = 0; // Is a 4 bit value

int* pixelVals = 7600 * malloc(sizeof(int)); 

int* IOSpace; // Connected from memory
// Assuming sizeof(int) = 4 Bytes

// 243,200 pixels grouped into 4 so practically 243200/4 = 60,800 pixels
// 60800 pixels with each pixel getting 4 bits => 30.4 kB to represent whole screen

// BLACK = 0
// RED = 1
// GREEN = 2
// BLUE = 4
// WHITE = 7, 6, 5, and 3

int main() {
    init();

    while(true) {
        xLoc = &getMouseData();
        yLoc = &getMouseData() + 1;
        left = &getMouseData() + 2;
        right = &getMouseData() + 3;
        middle = &getMouseData() + 4;

        selectedColor = setColor(xLoc, yLoc, left);

        xLoc = adjustMouseXCoord(xLoc);
        yLoc = adjustMouseYCoord(yLoc);

        updateMemoryBuffer(xLoc, yLoc, left, right, middle, selectedColor);
    }
}

/**
 * Sets up the memory buffer (background screen) to all white.
 * Sets input color (when no pen selected) to default color.
 * 
 * @return void
 * */
void init () {
    int i;
    for(i = 0; i < pixelVals.length; i++) {
        pixelVals[i] = 3; // white
    }
}

/**
 * Read mouse data at the mem-io (read only) address.
 * Some out registers to return the data.
 * 
 * @return int* xLocation, yLocation, LeftButtonPressed, RightButtonPressed, MiddleButtonPressed
 * */
int* getMouseData() {
    int* mouseData = 5*malloc(sizeof(int));

    // This code is a placeholder since I can't really show io space
    // But IOSpace[0] should represent x value which written to that
    // memory location via the mouse controller and so on.

    mouseData[0] = IOSpace[0]; // xLocation
    mouseData[1] = IOSpace[1]; // yLocation
    mouseData[2] = IOSpace[2]; // LeftButtonPressed
    mouseData[3] = IOSpace[3]; // RightButtonPressed
    mouseData[4] = IOSpace[4]; // MiddleButtonPressed

    return mouseData;
}

/**
 * @xLocation
 * @yLocation
 * @leftButtonPressed
 * 
 * Checks the mouse position and if it is in the color region
 * at the top, it updates the current color and returns it.
 * 
 * @return int currentColor;
 * */
int setColor(int xLocation, int yLocation, int leftButtonPressed) {
    if (leftButtonPressed) {
       if (adjustMouseYCoord(yLocation) < 100) {
           if (adjustMouseXCoord(xLocation) < 427) return 1; // red
           else if (adjustMouseXCoord(xLocation) > 427) {
               if (adjustMouseXCoord(xLocation) < 854) return 2; // green
           } 
           else if (adjustMouseXCoord(xLocation) > 854) {
               if (adjustMouseXCoord(xLocation) < 1280) return 4; // blue
           }
       }
   }
   return 0; // black - else statement is optional
}

/**
 * @xLocation
 * 
 * Adjusts the mouse coords to fit within our vitual screen space
 * Should be as simple as subtracting 220 from the y value then 
 * dividing both by 4.
 * 
 * @return int xLocation
 * */
int adjustMouseXCoord(int xLocation) {
    return xLocation / 4;
}

/**
 * @yLocation
 * 
 * Adjusts the mouse coords to fit within our vitual screen space
 * Should be as simple as subtracting 220 from the y value then 
 * dividing both by 4.
 * 
 * @return int yLocation
 * */
int adjustMouseYCoord(int yLocation) {
    return (yLocation - 220) / 4;
}

/**
 * @xLocation
 * @yLocation
 * @leftButtonPressed
 * @rightButtonPressed
 * @middleButtonPressed
 * @currentColor
 * 
 * Takes the current color, and mouse information.
 * Updates the memory buffer when appropriate based on
 * pressed buttons and mouse location.
 * 
 * @return void
 * */
void updateMemoryBuffer(int xLocation, int yLocation, int leftButtonPressed, int rightButtonPressed, int middleButtonPressed, int currentColor) {
    int selectedColor = currentColor; // default color value is set to black
    if (rightButtonPressed) selectedColor = 0; // Set color to draw with to white when right button is pressed
    else if (middleButtonPressed) selectedColor = 1; // Set color to draw with to black when middle button is pressed
   
   // Starting at 0, 0 but can easily add space taken up by the RGB "buttons" up top

    int memLocX = 3 * xLocation; // Calculate how much we need to go forward to find that location, assuming x[0:320]
    int memLocY = 960 * yLocation; // Calculate how much fown we need to go to find that location, assuming y[0:125]
    int memLoc = memLocX + memLocY;
    pixelVals[memLoc] = selectedColor; // Set memory location of pixel to the 3-bit selectedColor value as selectedColor = 3 bits
}
