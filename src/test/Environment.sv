`include "macros.sv"

// import scoreboard_pkg::Scoreboard;

class Environment;

   virtual dut_if dif;
   Generator gen;
   Driver drv;
   Checker chk;
   Monitor mon;
   // Config cfg;
   // Scoreboard sb;
   mailbox #(Transaction) gen2drv;
   mailbox #(Transaction) drv2mon;
   mailbox #(Verification) mon2chk;
   event transactionDone;

   function new(virtual dif dif);
      this.dif = dif;
      // cfg = new();
      // cfg.constraint_mode(0);
      // cfg.exactly_1000.constraint_mode(1);
   endfunction

   function void gen_cfg();
      // `SV_RAND_CHECK(cfg.randomize());
   endfunction

   function void build();
      // Initialize mailboxes
      gen2drv = new(1);

      // Initialize "transactors"
      gen = new(gen2drv);
      drv = new(gen2drv, dif, transactionDone);
      chk = new(mon2chk);
      mon = new(drv2mon, mon2chk, dif, transactionDone);
      // sb = new();
   endfunction

   task run();
      fork
         gen.run(cfg.run_for_n_trans);
         drv.run(cfg.run_for_n_trans);
         chk.run(); //TODO: add number of transactions? or just make below a join any.
         mon.run(); //TODO: add number of transactions? or just make below a join any.
      join
   endtask

   task wrap_up();
      fork
         gen.wrap_up();
         drv.wrap_up();
         chk.wrap_up(); //shows the scoreboard
         mon.wrap_up();
      join
      // $display("Number of Transactions compared: %0d", sb.num_compared);
   endtask

endclass
