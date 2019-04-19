import opcodes::*;

class Transaction;

   rand logic[15:0] instruction;
   
   function new(logic[15:0] instruction=16'h00);
      this.instruction = instruction;
   endfunction

   virtual function Transaction copy();
      copy = new(instruction);
   endfunction

   constraint valid_instruction {
      instruction[15:12] inside 
     {
      OPCODE_ADD,
      OPCODE_AND,
      OPCODE_NOT,
      OPCODE_JSR,
      OPCODE_BR,
      OPCODE_LD,
      OPCODE_ST,
      OPCODE_JMP,
      OPCODE_INV
      };
   }

endclass
