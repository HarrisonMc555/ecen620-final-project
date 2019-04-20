package verification_pkg;

class LC3_result;
    int cycles_taken = 0;
    logic[15:0] regs[7:0]
    int write_count;
    logic[15:0] write_address[$];
    logic[15:0] write_data[$];
    logic[15:0] PC;
    logic P_flag, Z_flag, N_flag;
endclass

class Verification;
    Transaction to_dut;
    LC3_result dut_result;
    LC3_result gold_result;
endclass

endpackage