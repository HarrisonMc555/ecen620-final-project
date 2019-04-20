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
      ADD,
      AND,
      NOT,
      JSR,
      BR,
      LD,
      ST,
      JMP,
      INV
      };
   }

endclass
