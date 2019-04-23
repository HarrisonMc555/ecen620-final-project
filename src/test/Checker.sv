import verification_pkg::Transaction;
import verification_pkg::Verification;
import scoreboard_pkg::Scoreboard;

virtual class Checker_cbs;
   virtual task post_tx(ref Transaction tr);
      // By default do nothing
   endtask

   virtual function logic is_done();
      return 1;
   endfunction

   pure virtual function real get_coverage;
   pure virtual function string coverage_name;
endclass

class Checker;
   //finishes populates the verification packet with data from the golden model
   Verification vr;
   Transaction tr;
   //gets a transaction from the checker
   mailbox #(Transaction) mbx_tr;
   mailbox #(Verification) mbx_vr;
   GoldenLC3 gold_dut;
   Scoreboard scb;
   Checker_cbs cbs[$];

   function new(
                input mailbox #(Transaction) mbx_tr,
                mailbox       #(Verification) mbx_vr
                );
      this.mbx_tr = mbx_tr;
      this.mbx_vr = mbx_vr;
      gold_dut = new();
   endfunction

   task run();
      LC3_result res;
      scb = new();
      vr = new();
      tr = new();
      forever begin
         mbx_tr.get(tr);
         mbx_vr.get(vr);
         $display("%0t Checker Transaction:", $time);
         $display("\tinstruction: %b", tr.instruction);
         $display("\tis_reset: %b", tr.is_reset);
         $display("\treset_clock_cycle: %0d", tr.reset_clock_cycle);
         res = gold_dut.run(tr);
         vr.gold_result = res;
         vr.to_dut = tr;
         foreach (cbs[i]) cbs[i].post_tx(vr.to_dut);
         scb.compare_expected(vr);
      end
   endtask

   task wrap_up();
      scb.display_scoreboard();
   endtask



endclass
