class Monitor;
    //reads the dut and packages the information nicely with its coresponding transaction
    Transaction tr;
    Verification vr;
    //gets a transaction from the driver
    mailbox #(Transaction) mbx_in;
    //this mailbox will pass along the verification object to the monitor
    mailbox #(Verification) mbx_out;
    event dut_reset;
    event dut_reset2;
    virtual dut_if dif;

    LC3_result result;
    LC3_result last_result;

    function new(
            input mailbox #(Transaction) mbx_in,
            mailbox #(Verification) mbx_out,
            virtual dut_if dif,
            event dut_reset
        );
        this.mbx_in = mbx_in;
        this.mbx_out = mbx_out;
        this.dut_reset = dut_reset;
        this.dif = dut_if;
    endfunction


    task time_dut();
        forever begin
            @(dif.cb)
            result.cycles_taken++;
            if(/*dut memory write conditions here*/) begin
                result.write_address.push_back(dut.memAddr);
                result.write_data.push_back(dut.memData);
                result.write_count++;
            end
            if(/*dut about to cycle conditions here*/) begin
                last_result = result;
                result = new();
                -> dut_reset;
                -> dut_reset2;
            end
        end
    endtask;


    task populate_verification();
        int i;
        //write all the information from the dut into the verification object
        @dut_reset2; //wait for the time_dut to be done watching the transaction
        last_result.PC = dut.PC
        for(i = 0; i < 8; i++) begin
            last_result.regs[i] = dut.regs[i];
        end
        last_result.P_flag = dut.P_flag;
        last_result.P_flag = dut.Z_flag;
        last_result.P_flag = dut.N_flag;
        last_result.to_dut = tr;
        vr.dut_result = last_result;
    endtask

    task read_mail();
        tr = new();
        forever begin
            mbx_in.get(tr);
            vr = new();
            //get the transaction out and store it in the verification packet
            populate_verification();
            mbx_out.put(vr);
        end
    endtask

    task run();
        result = new();
        fork
            time_dut();
            read_mail();
        join_any    //time should never finish but read mail should so wait on that.
    endtask

    task wrap_up();
    endtask
endclass