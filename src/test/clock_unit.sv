module clock_unit (output reg clock);
   parameter delay = 0;
   parameter half_cycle = 10;
   initial begin
      #delay clock = 0;
      forever #half_cycle clock = ~clock;
   end
endmodule
