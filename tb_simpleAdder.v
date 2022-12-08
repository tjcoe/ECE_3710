module tb_simpleAdder();
    reg [15:0] a, b;
    reg s;

    wire [15:0] c;

    SimpleAdder sa(.a(a), .b(b), .s(s), .c(c));

    initial begin
        a <= 16'd10; b <= 16'd5; s <= 1;
        #5;
        $display("signed 10 + 5 = %d", c);

        a <= 16'd10; b <= 16'd5; s <= 0;
        #5;
        $display("unsigned 10 + 5 = %d", c);

        a <= 16'd1000; b <= 16'b1111110111101000; s <= 1;
        #5;
        $display("signed 1000 + -536 = %d", c);

        a <= 16'd10; b <= 16'b1111110111101000; s <= 0;
        #5;
        $display("unsigned 10 + 65,000 = %d", c);
    end
endmodule