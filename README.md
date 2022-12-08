# ECE_3710

### Deliverables
* alu verilog code
* alu test bench verilog code - exhuastive self-checking test bench
* alu logic excell sheet with instruction set and control points
* RF verilog code
* RF test bench verilog code
* reg_init.dat file to initialize registers

## IO Addresses
   | IO Device          | Address      | Bit Index (16 Bits)   | Data Type       | Value Range              |
   | ---                | ---          | :---:                 | :---:           | :---:                    |
   | Right Mouse Button | 4089 (0xFF9) | 0                     |Boolean          | 1 pressed, 0 not pressed |
   | Middle Mouse Button| 4089 (0xFF9) | 1                     |Boolean          | 1 pressed, 0 not pressed |
   | Left Mouse Button  | 4089 (0xFF9) | 2                     |Boolean          | 1 pressed, 0 not pressed |
   | Mouse X Position   | 4088 (0xFF8) | [15:0]                |Unsigned Short   | 0-479                    | 
   | Mouse Y Position   | 4087 (0xFF7) | [15:0]                |Unsigned Short   | 0-649                    | 
