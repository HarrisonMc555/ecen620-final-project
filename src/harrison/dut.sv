module dut
  (input bit         clk, reset,
   input bit [15:0]  dataFromMemory,
   output bit [15:0] dataToMemory,
   output bit [15:0] address,
   output bit        writeEnable);

   datapath datapath(.*);
   controller controller(.*);

endmodule
