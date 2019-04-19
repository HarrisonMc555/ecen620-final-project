virtual class TestBase;

   Environment env;
   virtual dut_if dut_if;

   pure virtual task run_test();

   function new(virtual dut_if dut_if);
      this.dut_if = dut_if;
      env = new(dut_if);
   endfunction

endclass
