module tb_debuggingAsm();
    reg clk, reset, start;
    wire ps2_clk, ps2_data;

    wire hSync, vSync, bright, clk_25Mhz, VGA_SYNC_N;
    wire [7:0] red, green, blue;
    wire [2:0] btns;
    wire [41:0] hexDisplays;

    CpuMem uut(clk, reset, start, ps2_clk, ps2_data, hSync, vSync, bright, clk_25Mhz, VGA_SYNC_N, red, green, blue, btns, hexDisplays);

    initial begin
        reset = 1;
        start = 0;
        #22 reset = 0;
        #22 reset = 1;
        #22 start = 1;
    end

    always begin
        clk <= 0; #5 clk <= 1; #5;
    end
endmodule