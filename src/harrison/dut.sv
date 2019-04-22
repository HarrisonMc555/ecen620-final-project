
import lc3::*;

module dut
  (input bit         clk, reset,
   input bit [15:0]  dataFromMemory,
   output bit [15:0] dataToMemory,
   output bit [15:0] address,      //is this the same as memory address
   output bit        writeEnable); //is this the same as writeMemory?

   logic [15:0] ir, memoryAddress;
   logic flagN, flagZ, flagP, writeMemory;
   logic enaMARM, selMAR, enaPC, ldPC, regWE, enaMDR,
          ldMAR, ldMDR, memWE, selMDR, enaALU, ldIR, selEAB1,
          flagWE;
   logic [1:0] selPC, selEAB2;
   logic [2:0] DR, SR1, SR2;
   aluControl_t aluControl;

   datapath datapath(.*);
   controller controller(.*);

endmodule
