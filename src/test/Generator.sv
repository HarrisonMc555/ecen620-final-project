`include "macros.sv"

// import Transaction;

class Generator;

   mailbox #(Transaction) gen2drv;
   Transaction blueprint;

   function new(input mailbox #(Transaction) gen2drv);
      this.gen2drv = gen2drv;
      blueprint = new();
      // Set constraints
      // blueprint.header.turn_on_valid_constraints();
   endfunction

   task run(input int num_trans = 10);
      Transaction trans;
      repeat (num_trans) begin
         `SV_RAND_CHECK(blueprint.randomize());
         gen2drv.put(trans);
      end
   endtask

   task wrap_up();
      // Do nothing
   endtask

endclass;
