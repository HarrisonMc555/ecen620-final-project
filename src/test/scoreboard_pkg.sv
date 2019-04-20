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

   import Verification_pkg::*;
   
   // Parameterized class to do compare
class comparator #(type T=bit[3:0]);
   static int num_errors = 0;
   function void compare(input string name, input T actual, input T expected);
      if (expected !== actual) begin
         $display("%0t: ERROR for %s, expected=0x%0h != actual=0x%0h", $time, name, expected, actual);
         num_errors++;
      end
   endfunction   
   function void compare_number(input string name, int number, input T actual, input T expected);
      if (expected !== actual) begin
         $display("%0t: ERROR for %s number %0d, expected=0x%0h != actual=0x%0h", $time, name, number, expected, actual);
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
      int i;
      num_compared++;
      compare_clocks.compare("cycles to complete", vr.dut_result.cycles_taken, vr.gold_result.cycles_taken);
      compare_PC.compare("PC value", vr.dut_result.PC, vr.gold_result.PC);
      compare_writes.compare("times writen", vr.dut_result.write_count, vr.gold_result.write_count);
      for(i = 0; (i < vr.dut_result.write_count) && (i < vr.gold_result.write_count); i++) begin
         compare_address.compare("write address", vr.dut_result.write_address[i], vr.gold_result.wriet_address[i])
         compare_data.compare("write data", vr.dut_result.write_data[i], vr.gold_result.write_data[i]);
      end
      for(i = 0; i < 8; i++) begin
         compare_regs.compare_number("register", i, vr.dut_result.regs[i], vr.gold_result.regs[i]);
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