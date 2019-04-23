package verification_pkg;

   import opcodes::*;

class Transaction;

   rand logic[15:0] instruction;
   rand logic is_reset;
   rand int reset_clock_cycle;
   logic[15:0] mem_data[$];
   
   function new(logic[15:0] instruction=16'h00);
      this.instruction = instruction;
   endfunction

   virtual function Transaction copy();
      copy = new(instruction);
   endfunction

   constraint valid_instruction {
      instruction[15:12] inside 
     {
      ADD,
      AND,
      NOT,
      JSR,
      BR,
      LD,
      ST,
      JMP
      };
   }

   constraint valid_clock_cycle {
      reset_clock_cycle inside {[0:10]};
   }

   constraint no_reset {
      is_reset == 0;
   }

endclass

class LC3_result;
   int          cycles_taken = 0;
   logic [15:0] regs[7:0];
   int          write_count;
   logic [15:0] write_address[$];
   logic [15:0] write_data[$];
   logic [15:0] PC;
   logic        P_flag, Z_flag, N_flag;
endclass

class Verification;
   Transaction to_dut;
   LC3_result dut_result;
   LC3_result gold_result;
endclass

endpackage
