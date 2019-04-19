module top;

   bit clk, rst_n;
   dut_if dut_if();

   clock_unit clock(clk);
   test test();
   dut dut();

endmodule
