class TestRegistry;

   static TestBase registry[string];

   static function void register(string name, TestBase t);
      registry[name] = t;
      $display("Registered Test %0s", name);
   endfunction

   static function TestBase get_test();
      string name;

      if (!$value$plusargs("TESTNAME=%s", name)) begin
         $display("ERROR: No +TESTNAME switch found");
         $finish(1);
      end else begin
         $display("%m found +TESTNAME=%s", name);
      end

      if (!registry.exists(name)) begin
         $display("ERROR: '%0s' is not a valid test name", name);
         $finish(1);
      end
      return registry[name];
   endfunction

endclass



// Checker_cbs instances ///////////////////////////////////////////////////////

import opcodes::*;

class AllOpcodesCb extends Checker_cbs;
   Transaction cur_tr;
   const string NAME = "All opcodes";

   covergroup cg;
      coverpoint cur_tr.instruction[15:12] {
         bins valid_opcodes[] = {ADD,
                                 AND,
                                 NOT,
                                 JSR,
                                 BR,
                                 LD,
                                 ST,
                                 STR,
                                 STI,
                                 JMP};
      }
   endgroup

   function new;
      cg = new();
      cg.set_inst_name(NAME);
   endfunction

   task post_tx(ref Transaction tr);
      cur_tr = tr;
      cg.sample();
   endtask

   virtual function logic is_done();
      return cg.get_coverage() == 100.0;
   endfunction

   virtual function real get_coverage;
      return cg.get_coverage();
   endfunction

   virtual function string coverage_name();
      return NAME;
   endfunction
endclass


// TestBase instances //////////////////////////////////////////////////////////

class TestRandomGood extends TestBase;

   function new(virtual dut_if dut_if);
      super.new(dut_if);
      TestRegistry::register("TestRandomGood", this);
   endfunction

   virtual task run_test();
      $display("%m");
      env.gen_cfg();
      env.build();
      create_callbacks();
      env.run();
      env.wrap_up();
   endtask

   task create_callbacks;
      AllOpcodesCb cb1 = new();
      env.chk.cbs.push_back(cb1);
   endtask
endclass

class TestWithBad extends TestBase;

   function new(virtual dut_if dut_if);
      super.new(dut_if);
      TestRegistry::register("TestWithBad", this);
   endfunction

   virtual task run_test();
      // Driver_cb_send_to_scoreboard scoreboard_callback;
      // $display("%m");
      env.gen_cfg();
      env.build();
      // scoreboard_callback = new(env.sb);
      // env.drv.cbs.push_back(scoreboard_callback);
      env.gen.blueprint.valid_instruction.constraint_mode(0);
      env.run();
      env.wrap_up();
   endtask

endclass
