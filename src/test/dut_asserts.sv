module dut_asserts
  (input bit        clk, reset,
   input bit [15:0] dataFromMemory,
   input bit [15:0] dataToMemory,
   input bit [15:0] address,
   input bit        writeEnable,

   // dallin ///////////////////////////////////////////////////////////////////
   logic            Nf, Pf, Zf,
   logic [15:0]     PC,
   logic [15:0]     last_pc,
   logic [15:0]     regs [8],

   logic [15:0]     instruction,
   logic [ 3:0]     opcode,
   logic [ 2:0]     sr1,
   logic [ 2:0]     sr2,
   logic [ 2:0]     dr,
   logic            imm_sw,
   logic [15:0]     imm5,
   logic            br_n,
   logic            br_z,
   logic            br_p,
   logic [ 2:0]     base_r,
   logic            jsr_sw,
   logic [15:0]     pcoffset11,
   logic [15:0]     pcoffset9,
   logic [15:0]     pcoffset6,
   logic [ 7:0]     trapvect8,
   logic [15:0]     ir,
  
   logic [15:0]     alu_out);


   // harrison /////////////////////////////////////////////////////////////////
   // logic [15:0]      ir,
   // logic             flagN, flagZ, flagP, writeMemory,
   // logic             enaMARM, selMAR, enaPC, ldPC, regWE, enaMDR,
   //                   ldMAR, ldMDR, memWE, selMDR, enaALU, ldIR, selEAB1,
   //                   flagWE,
   // logic [1:0]       selPC, selEAB2,
   // logic [2:0]       DR, SR1, SR2,
   // aluControl_t aluControl);

   // import lc3::*; // harrison

`include "assert_macros.sv"

   ERR_ONLY_ONE_NZP_FLAG_SHOULD_BE_HIGH_AT_ONCE:
     `assert_clk_xrst(Nf + Pf + Zf == 1); // dallin
   // `assert_clk_xrst(flagN + flagP + flagZ == 1); // harrison
   ERR_AT_LEAST_ONE_NZP_FLAG_SHOULD_BE_HIGH_ALWAYS:
     `assert_clk_xrst(Nf | Pf | Zf); // dallin
   // `assert_clk_xrst(flagN + flagP + flagZ == 1); // harrison

   property err_should_load_ir_after_fetch1;
      logic [15:0]  data;
      // 1 == FETCH1
      @(posedge clk) ($root.top.dut.state == 1, data=dataFromMemory) |-> ##1 (ir === data); // dallin
      // @(posedge clk) ($root.top.dut.curState == STATE_FETCH1, data=dataFromMemory) |-> ##1 (ir === data); // harrison
   endproperty 
   ERR_SHOULD_LOAD_IR_AFTER_FETCH1:
     assert property (err_should_load_ir_after_fetch1);

endmodule
