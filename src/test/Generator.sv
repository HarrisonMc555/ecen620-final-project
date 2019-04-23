`include "macros.sv"

import verification_pkg::Transaction;

class Generator;

   mailbox #(Transaction) gen2drv;
   Transaction blueprint;

   function new(input mailbox #(Transaction) gen2drv);
      this.gen2drv = gen2drv;
      blueprint = new();
      // Set constraints
      // blueprint.header.turn_on_valid_constraints();
   endfunction

   task run();
      Transaction trans;
      forever begin
         `SV_RAND_CHECK(blueprint.randomize());
         gen2drv.put(blueprint.copy());
      end
   endtask

   task wrap_up();
      // Do nothing
   endtask

endclass;
