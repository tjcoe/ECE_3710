module zerodetect #(parameter WIDTH = 16)
                   (input [WIDTH - 1:0] a,
                    output              y);
    assign y = (a == 0);
endmodule

module flopenr #(paramter WIDTH = 16)
                (input clk, reset, en,
                 input [WIDTH - 1:0] d,
                 output reg [WIDTH - 1:0] q);
    always @(posedge clk) begin
        if (~reset)  q <= 0;
        else if (en) q <= d;
    end
endmodule