import verification_pkg::Transaction;
import verification_pkg::Verification;
import scoreboard_pkg::Scoreboard;

class Checker;
   //finishes populates the verification packet with data from the golden model
   Verification vr;
   Transaction tr;
   //gets a transaction from the checker
   mailbox #(Transaction) mbx_tr;
   mailbox #(Verification) mbx_vr;
   GoldenLC3 gold_dut;
   Scoreboard scb;

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
         res = gold_dut.run(tr);
         vr.gold_result = res;
         scb.compare_expected(vr);
      end
   endtask

   task wrap_up();
      scb.display_scoreboard();
   endtask



endclass
