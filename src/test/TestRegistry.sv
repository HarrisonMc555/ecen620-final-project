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
   logic [3:0] opcode;
   const string NAME = "All opcodes";

   covergroup cg;
      coverpoint opcode {
      // coverpoint cur_tr.instruction[15:12] {
         bins valid_opcodes[] = {
                                 ADD,
                                 AND,
                                 NOT,
                                 BR,
                                 JMP,
                                 JSR,
                                 LD,
                                 LDI,
                                 LDR,
                                 LEA,
                                 ST,
                                 STI,
                                 STR,
                                 TRAP
                                 };
      }
   endgroup

   function new;
      cg = new();
      cg.set_inst_name(NAME);
   endfunction

   task post_tx(ref Transaction tr);
      opcode = tr.instruction[15:12];
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



class AllSourcesCb extends Checker_cbs;
   logic [3:0] opcode;
   logic [2:0] src;
   const string NAME = "All sources";

   covergroup cg;
      coverpoint opcode {
         bins valid_opcodes[] = {
                                 ADD,
                                 AND,
                                 NOT,
                                 ST,
                                 STI,
                                 STR
                                 };
         
      }
      coverpoint src;
      cross opcode, src;
   endgroup

   function new;
      cg = new();
      cg.set_inst_name(NAME);
   endfunction

   task post_tx(ref Transaction tr);
      opcode = tr.instruction[15:12];
      unique case (opcode)
        ADD     : src = tr.instruction[8:6];
        AND     : src = tr.instruction[8:6];
        NOT     : src = tr.instruction[8:6];
        ST      : src = tr.instruction[11:9];
        STI     : src = tr.instruction[11:9];
        STR     : src = tr.instruction[8:6];
        default : src = 3'bXXX; // Let's see some red if we didn't do this right
      endcase
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


class AllSecondSourcesCb extends Checker_cbs;
   logic [3:0] opcode;
   logic [2:0] src;
   const string NAME = "All second sources";

   covergroup cg;
      coverpoint opcode {
         bins valid_opcodes[] = {
                                 ADD,
                                 AND
                                 };
         
      }
      coverpoint src;
      cross opcode, src;
   endgroup

   function new;
      cg = new();
      cg.set_inst_name(NAME);
   endfunction

   task post_tx(ref Transaction tr);
      opcode = tr.instruction[15:12];
      unique case (opcode)
        ADD     : src = tr.instruction[2:0];
        AND     : src = tr.instruction[2:0];
        default : src = 3'bXXX; // Let's see some red if we didn't do this right
      endcase
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


class AllBaseRegistersCb extends Checker_cbs;
   logic [3:0] opcode;
   logic [2:0] src;
   const string NAME = "All second sources";

   covergroup cg;
      coverpoint opcode {
         bins valid_opcodes[] = {
                                 JMP,
                                 JSR,
                                 LDR,
                                 STR
                                 };
         
      }
      coverpoint src;
      cross opcode, src;
   endgroup

   function new;
      cg = new();
      cg.set_inst_name(NAME);
   endfunction

   task post_tx(ref Transaction tr);
      opcode = tr.instruction[15:12];
      if (opcode == JSR && tr.instruction[11] == 1'b1) return;
      src = tr.instruction[8:6];
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



class AllDestinationsCb extends Checker_cbs;
   logic [3:0] opcode;
   logic [2:0] dst;
   const string NAME = "All destinations";

   covergroup cg;
      coverpoint opcode {
         bins valid_opcodes[] = {
                                 ADD,
                                 AND,
                                 NOT,
                                 LD,
                                 LDI,
                                 LDR,
                                 LEA
                                 };
         
      }
      coverpoint dst;
      cross opcode, dst;
   endgroup

   function new;
      cg = new();
      cg.set_inst_name(NAME);
   endfunction

   task post_tx(ref Transaction tr);
      opcode = tr.instruction[15:12];
      dst = tr.instruction[11:9];
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
      AllSourcesCb cb2 = new();
      AllSecondSourcesCb cb3 = new();
      AllBaseRegistersCb cb4 = new();
      AllDestinationsCb cb5 = new();
      env.chk.cbs.push_back(cb1);
      env.chk.cbs.push_back(cb2);
      env.chk.cbs.push_back(cb3);
      env.chk.cbs.push_back(cb4);
      env.chk.cbs.push_back(cb5);
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
