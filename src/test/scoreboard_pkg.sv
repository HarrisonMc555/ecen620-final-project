//////////////////////////////////////////////////////////////////////////////////////////
// Purpose: Package that defines the scoreboard for
//          Chap_8_Advanced_OOP_and_Testbench_Guidelines/homework_solution
// Author: Greg Tumbush
//
// REVISION HISTORY:
// $Log: scoreboard_pkg.sv,v $
// Revision 1.1  2011/05/29 19:16:11  tumbush.tumbush
// Check into cloud repository
//
// Revision 1.1  2011/03/29 19:28:37  Greg
// Initial check-in
//
//////////////////////////////////////////////////////////////////////////////////////////

package scoreboard_pkg;

   import verification_pkg::*;

   // Parameterized class to do compare
class comparator #(type T=bit[3:0]);
   static int num_errors = 0;
   function void compare(input Verification vr, input string name, input T actual, input T expected);
      string  instruction;
      if (vr != null && vr.to_dut != null) begin
         instruction = $sformatf("instruction = %16b:", vr.to_dut.instruction);
      end else begin
         instruction = "????????????????";
      end
      if (expected !== actual) begin
         $display("%0t: ERROR instruction %0s, %20s: expected=0x%0h != actual=0x%0h (%0d != %0d)", 
                  $time, instruction, name, expected, actual, expected, actual);
         num_errors++;
      end
   endfunction
endclass

   // Class scoreboard that instantiates the comparator class
   // for the 4, 8, and 16-bit fields we want to compare
   // and defines the compare_expected function.
class Scoreboard;
   static int num_compared = 0;
   comparator #(int) compare_clocks;
   comparator #(int) compare_writes;
   //comparator #(bit [7:0]) compare_8bit;
   comparator #(bit [15:0]) compare_regs;
   comparator #(bit [15:0]) compare_address;
   comparator #(bit [15:0]) compare_data;
   comparator #(bit [15:0]) compare_PC;


   // Instantiate the 3 comparators.
   function new();
      compare_clocks = new();
      compare_writes = new();
      compare_regs = new();
      compare_address = new();
      compare_data = new();
      compare_PC = new();
   endfunction // new

   // Compare the expected values of the version, ihl, total length, and the header checksum
   function void compare_expected(input Verification vr);
      int     i;
      num_compared++;
      compare_clocks.compare(vr, "cycles to complete", vr.dut_result.cycles_taken, vr.gold_result.cycles_taken);
      compare_PC.compare(vr, "PC value", vr.dut_result.PC, vr.gold_result.PC);
      compare_writes.compare(vr, "times writen", vr.dut_result.write_count, vr.gold_result.write_count);
      for(i = 0; (i < vr.dut_result.write_count) && (i < vr.gold_result.write_count); i++) begin
         compare_address.compare(vr, "write address", vr.dut_result.write_address[i], vr.gold_result.write_address[i]);
         compare_data.compare(vr, "write data", vr.dut_result.write_data[i], vr.gold_result.write_data[i]);
      end
      for(i = 0; i < 8; i++) begin
         compare_regs.compare(vr, $sformatf("register %0d", i), vr.dut_result.regs[i], vr.gold_result.regs[i]);
      end
   endfunction // compare_expected

   function void display_scoreboard();

      $display("Transactions compared %0d", num_compared);
      $display("Cycle count errors %0d", compare_clocks.num_errors);
      $display("PC value errors %0d", compare_PC);
      $display("Write count errors %0d", compare_PC);
      $display("Write address errors %0d", compare_address);
      $display("Write address errors %0d", compare_data);
      $display("Write address errors %0d", compare_regs);
   endfunction

endclass : Scoreboard

endpackage
