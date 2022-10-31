module tb_memoryFSM();

   reg clk, reset, advance;
	wire [9:0] leds;
	wire [13:0] left_7_seg_pair, right_7_seg_pair;

   ECE_3710 dut(.clk(clk), .reset(reset), .advance(advance), .leds(leds), .left_7_seg_pair(left_7_seg_pair), .right_7_seg_pair(right_7_seg_pair));


   initial 
   begin 
		clk = 0;
      reset = 1;
      advance = 1;
		forever 
      begin
   		#20 clk = ~clk;
		end 
	end


   initial
   begin
      forever
      begin
         #100 advance = ~advance;
      end
   end


endmodule