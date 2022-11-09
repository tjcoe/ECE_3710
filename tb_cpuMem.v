module tb_cpuMem();
    reg clk, reset;

    CpuMem uut(.clk(clk), .reset(reset));

    initial begin
        reset <= 1;
        #22 reset <= 0;
        #22 reset <= 1;
    end

    always begin
        clk <= 0; #5 clk <= 1; #5;
    end
endmodule