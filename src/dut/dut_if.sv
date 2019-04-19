interface dut_if;
   logic       clk, reset;
   logic [7:0] dataToMemory, dataFromMemory;
   logic [7:0] address;
   logic       writeEnable;

   modport Memory(input  clk,
                  input  reset,
                  input  dataToMemory,
                  output dataFromMemory,
                  input  address,
                  input  writeEnable);

   modport Datapath(input  clk,
                    input  reset,
                    output dataToMemory,
                    input  dataFromMemory,
                    output address,
                    output writeEnable);
endinterface
