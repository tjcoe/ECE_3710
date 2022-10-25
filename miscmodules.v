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

module flopr #(parameter WIDTH = 16)
              (input clk, reset,
               input      [WIDTH-1:0] d, 
               output reg [WIDTH-1:0] q);

   always @(posedge clk)
      if   (~reset) q <= 0;
      else q <= d;
endmodule

module mux4 #(parameter WIDTH = 16)
             (input      [WIDTH-1:0] d0, d1, d2, d3,
              input      [1:0]       sel, 
              output reg [WIDTH-1:0] res);

   always @(*)
      case(sel)
         2'b00: res <= d0;
         2'b01: res <= d1;
         2'b10: res <= d2;
         2'b11: res <= d3;
      endcase
endmodule

module mux2 #(parameter WIDTH = 16)
             (input  [WIDTH-1:0] d0, d1, 
              input              sel, 
              output [WIDTH-1:0] res);

   assign res = sel ? d1 : d0; 
endmodule