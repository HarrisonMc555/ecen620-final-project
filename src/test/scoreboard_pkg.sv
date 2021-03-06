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
   int num_errors = 0;
   // static int num_errors = 0;
   function void compare(input Verification vr, input string name, input T actual, input T expected);
      string  instruction;
      if (vr != null && vr.to_dut != null) begin
         instruction = $sformatf("%16b", vr.to_dut.instruction);
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
   comparator #(bit) compare_Nf;
   comparator #(bit) compare_Zf;
   comparator #(bit) compare_Pf;


   // Instantiate the 3 comparators.
   function new();
      compare_clocks = new();
      compare_writes = new();
      compare_regs = new();
      compare_address = new();
      compare_data = new();
      compare_PC = new();
      compare_Nf = new();
      compare_Zf = new();
      compare_Pf = new();
   endfunction // new

   // Compare the expected values of the version, ihl, total length, and the header checksum
   function void compare_expected(input Verification vr);
      int     i;
      num_compared++;
      if (num_compared % 100 == 0) begin
         $display("At time %0t", $time);
         $display("\tnum_compared = %0d", num_compared);
         $display("\t compare_clocks errors = %0d", compare_clocks.num_errors);
         $display("\t compare_writes errors = %0d", compare_writes.num_errors);
         $display("\t compare_regs errors = %0d", compare_regs.num_errors);
         $display("\t compare_address errors = %0d", compare_address.num_errors);
         $display("\t compare_data errors = %0d", compare_data.num_errors);
         $display("\t compare_PC errors = %0d", compare_PC.num_errors);
         $display("\t compare_Nf errors = %0d", compare_Nf.num_errors);
         $display("\t compare_Zf errors = %0d", compare_Zf.num_errors);
         $display("\t compare_Pf errors = %0d", compare_Pf.num_errors);
      end
      if (~vr.to_dut.is_reset) begin
         compare_clocks.compare(vr, "cycles to complete", vr.dut_result.cycles_taken, vr.gold_result.cycles_taken);
         compare_writes.compare(vr, "times written", vr.dut_result.write_count, vr.gold_result.write_count);
         for(i = 0; (i < vr.dut_result.write_count) && (i < vr.gold_result.write_count); i++) begin
            compare_address.compare(vr, "write address", vr.dut_result.write_address[i], vr.gold_result.write_address[i]);
            compare_data.compare(vr, "write data", vr.dut_result.write_data[i], vr.gold_result.write_data[i]);
         end
      end
      compare_PC.compare(vr, "PC value", vr.dut_result.PC, vr.gold_result.PC);
      compare_Nf.compare(vr, "N flag", vr.dut_result.N_flag, vr.gold_result.N_flag);
      compare_Zf.compare(vr, "Z flag", vr.dut_result.Z_flag, vr.gold_result.Z_flag);
      compare_Pf.compare(vr, "P flag", vr.dut_result.P_flag, vr.gold_result.P_flag);
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
