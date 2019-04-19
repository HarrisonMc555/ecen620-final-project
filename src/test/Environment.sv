`include "macros.sv"

// import scoreboard_pkg::Scoreboard;

class Environment;

   virtual dut_if dut_if;
   Generator gen;
   Driver drv;
   // Config cfg;
   // Scoreboard sb;
   mailbox #(Transaction) gen2drv;

   function new(virtual dut_if dut_if);
      this.dut_if = dut_if;
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
      drv = new(gen2drv, dut_if);
      // sb = new();
   endfunction

   task run();
      fork
         gen.run(cfg.run_for_n_trans);
         drv.run(cfg.run_for_n_trans);
      join
   endtask

   task wrap_up();
      fork
         gen.wrap_up();
         drv.wrap_up();
      join
      // $display("Number of Transactions compared: %0d", sb.num_compared);
   endtask

endclass
