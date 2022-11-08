module SimpleAdder(input [15:0] a, b, input s, output [15:0] c);

    wire signed [16:0] signed_a;
    wire signed [16:0] signed_b;


    wire signed [16:0] sig = signed_a + signed_b;
    wire        [16:0] unsig = a + b;

    assign signed_a = a;
    assign signed_b = b;
    assign c = (s == 1) ? sig[15:0] : unsig;
endmodule