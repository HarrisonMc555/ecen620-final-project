`include "macros.sv"

// import scoreboard_pkg::Scoreboard;

class Environment;

   // Generator gen;
   // Driver drv;
   // Config cfg;
   // Scoreboard sb;
   // mailbox #(packet) gen2drv;

   function new();
      // cfg = new();
      // cfg.constraint_mode(0);
      // cfg.exactly_1000.constraint_mode(1);
   endfunction

   function void gen_cfg();
      // `SV_RAND_CHECK(cfg.randomize());
   endfunction

   function void build();
      // Initialize mailboxes
      // gen2drv = new(1);

      // Initialize "transactors"
      // gen = new(gen2drv);
      // drv = new(gen2drv);
      // sb = new();
   endfunction

   task run();
      fork
         // gen.run(cfg.run_for_n_trans);
         // drv.run(cfg.run_for_n_trans);
      join
   endtask

   task wrap_up();
      fork
         // gen.wrap_up();
         // drv.wrap_up();
         // $display("Number of packets compared: %0d", sb.num_compared);
      join
   endtask

endclass
