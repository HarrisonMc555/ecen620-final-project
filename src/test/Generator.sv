`include "macros.sv"

import verification_pkg::Transaction;

class Generator;

   mailbox #(Transaction) gen2drv;
   Transaction blueprint;

   function new(input mailbox #(Transaction) gen2drv);
      this.gen2drv = gen2drv;
      blueprint = new();
   endfunction

   task run();
      forever begin
         `SV_RAND_CHECK(blueprint.randomize());
         gen2drv.put(blueprint.copy());
      end
   endtask

   task wrap_up();
      // Do nothing
   endtask

endclass;
