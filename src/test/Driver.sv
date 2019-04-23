class Driver;

   // Driver_cbs cbs[$];
   mailbox #(Transaction) gen2drv;
   mailbox #(Transaction) drv2chk;
   virtual dut_if dif;
   mailbox #(bit) transactionDone;

   logic[15:0] mem_data = 0;

   function new(input mailbox #(Transaction) gen2drv,
                input mailbox #(Transaction) drv2chk,
                virtual dut_if               dif,
                input mailbox #(bit)         transactionDone);
      this.gen2drv = gen2drv;
      this.drv2chk = drv2chk;
      this.dif = dif;
      this.transactionDone = transactionDone;
   endfunction

   task run();
      Transaction trans = new();
      dif.reset = 1;
      repeat (5) @(posedge dif.clk);
      @(negedge dif.clk);
      dif.reset = 0;
      forever begin
         gen2drv.peek(trans);
         // foreach (cbs[i]) cbs[i].pre_tx(trans, drop);
         // @(posedge dif.clk);
         transmit(trans);
         // foreach (cbs[i]) cbs[i].post_tx(trans);
         gen2drv.get(trans);
      end
   endtask

   task wrap_up();
      // Do nothing
   endtask

   task transmit(input Transaction trans);
      bit bogus;
      $display("%0t Driver Transaction:", $time);
      $display("\tinstruction: %b", trans.instruction);
      $display("\tis_reset: %b", trans.is_reset);
      $display("\treset_clock_cycle: %0d", trans.reset_clock_cycle);
      $display("%0t Driver putting transaction into drv2chk: before", $time);
      drv2chk.put(trans);
      $display("%0t Driver putting transaction into drv2chk: after", $time);
      if (trans.is_reset) begin
         $display("Transaction is reset!!");
         $display("\tcycle: %0d", trans.reset_clock_cycle);
         $display("\tone more cycle");
         @(negedge dif.clk); // Cycle where IR is loaded into MAR
         // golden.memory[dif.address] = trans.instruction;
         dif.dataFromMemory = trans.instruction;
         if (trans.reset_clock_cycle == 1) begin
            $display("\tIt was in cycle 1", trans.reset_clock_cycle);
            dif.reset = 1;
            @(negedge dif.clk);
            dif.reset = 0;
            trans.mem_data.push_back(mem_data);
            transactionDone.get(bogus);
            return;
         end
         $display("\tone more cycle");

         mem_data = $urandom();
         repeat (trans.reset_clock_cycle - 2) begin
            if (transactionDone.num() > 0) begin
               // Transaction finished before we could reset.
               // That's fine.
               $display("Darn, no reset. Before: %0t", $time);
               trans.mem_data.push_back(mem_data);
               transactionDone.get(bogus);
               $display("Darn, no reset. After:  %0t", $time);
               return;
            end
            @(negedge dif.clk);
            dif.dataFromMemory = mem_data;
            $display("\tone more cycle");
         end
         // If we get here, we will reset.
         $display("Actually reset!");
         dif.reset = 1;
         @(negedge dif.clk);
         dif.reset = 0;
         trans.mem_data.push_back(mem_data);
         transactionDone.get(bogus);

      end else begin
         @(negedge dif.clk); // Cycle where IR is loaded into MAR
         // golden.memory[dif.address] = trans.instruction;
         dif.dataFromMemory = trans.instruction;
         @(negedge dif.clk);
         mem_data = $urandom();
         dif.dataFromMemory = mem_data;
         trans.mem_data.push_back(mem_data);
         transactionDone.get(bogus);
      end
   endtask;

endclass;
