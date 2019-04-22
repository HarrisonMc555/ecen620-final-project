module top;

   //bit clk, rst_n;
   dut_if dut_if();

   initial begin
   dut_if.clk <= 0;
   dut_if.reset <= 0;
   //period of 100ns;
   forever begin
     #50ns dut_if.clk <= ~dut_if.clk;
   end
   end 

   //clock_unit clock(clk);
   test test(dut_if);
   dut dut(.clk(dut_if.clk),
           .reset(dut_if.reset),
           .dataFromMemory(dut_if.dataFromMemory),
           .dataToMemory(dut_if.dataToMemory),
           .address(dut_if.address),
           .writeEnable(dut_if.writeEnable));

endmodule
