class Checker;
    //finishes populates the verification packet with data from the golden model
    Verification vr;
    //gets a transaction from the checker
    mailbox #(Transaction) mbx_in;
    GoldenLC3 gold_dut;
    Scoreboard scb;

    function new(input mailbox #(Transaction) mbx_in, input mailbox #(Verification) mbx_out);
        this.mbx_in = mbx_in;
        this.mbx_out = mbx_out;
        gold_dut = new();
    endfunction

    task run();
        LC3_result res;
        scb = new();
        vr = new();
        forever begin
            mbx_in.get(vr);
            res = gold_dut.run()
            vr.gold_result = res;
            scb.compare_expected(vr);
        end
    endtask

    task wrap_up();
    endtask

    

endclass