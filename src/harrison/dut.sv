module dut_harrison
  (input bit           clk, reset,
   input logic [15:0]  dataFromMemory,
   output logic [15:0] dataToMemory,
   output logic [15:0] address,
   output logic        writeEnable);

   datapath datapath(.*);
   controller controller(.*);

endmodule
