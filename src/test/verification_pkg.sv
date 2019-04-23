package verification_pkg;

   import opcodes::*;

class Transaction;

   rand logic [3:0] opcode;
   rand logic [11:0] other_bits;
   rand logic [15:0] instruction;
   rand bit is_reset;
   rand int reset_clock_cycle;
   logic [15:0] mem_data[$];

   function new(logic[15:0] instruction=16'h00);
      this.instruction = instruction;
   endfunction

   virtual function Transaction copy();
      copy = new(instruction);
   endfunction

   constraint valid_instruction {
      opcode inside {
                     ADD,
                     AND,
                     NOT,
                     BR,
                     JMP,
                     JSR,
                     LD,
                     LDI,
                     LDR,
                     LEA,
                     ST,
                     STI,
                     STR,
                     TRAP
                     };
   }

   constraint valid_not_instruction {
      (opcode == NOT) -> (other_bits[5:0] == 6'b111111);
   }

   constraint valid_jmp_instruction_high_bits {
      (opcode == JMP) -> (other_bits[11:9] == 0);
   }

   constraint valid_jmp_instruction_low_bits {
      (opcode == JMP) -> (other_bits[ 5:0] == 0);
   }

   constraint valid_jsr_instruction_high_bits {
      opcode == JSR && other_bits[11] == 0 -> other_bits[11:9] == 0;
   }

   constraint valid_jsr_instruction_low_bits {
      opcode == JSR && other_bits[11] == 0 -> other_bits[ 5:0] == 0;
   }

   constraint valid_trap_instruction {
      (opcode == TRAP) -> (other_bits[11:8] == 4'b0000);
   }

   constraint order {
      solve opcode before other_bits;
   }

   constraint form_instruction {
      instruction == {opcode, other_bits};
   }

   constraint valid_clock_cycle {
      // reset_clock_cycle inside {[0:10]};
      reset_clock_cycle < 10;
   }

   // constraint no_reset {
   //    is_reset == 0;
   // }

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
