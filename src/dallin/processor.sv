

module dut(clk, reset, memWE, memAddrIn, memDataIn, memDataOut);
    input  logic        clk, reset;
    output logic        memWE;
    output logic [15:0] memAddrIn, memDataIn;
    input  logic [15:0] memDataOut;

    const logic [3:0] ADD  = 4'b0001;
    const logic [3:0] AND  = 4'b0101;
    const logic [3:0] NOT  = 4'b1001;
    const logic [3:0] BR   = 4'b0000;
    const logic [3:0] JMP  = 4'b1100;
    const logic [3:0] JSR  = 4'b0100;
    //const logic[3:0] RET  = 4'b1100; //same as jmp
    const logic [3:0] LD   = 4'b0010;
    const logic [3:0] LDI  = 4'b1010;
    const logic [3:0] LDR  = 4'b0110;
    const logic [3:0] LEA  = 4'b1110;
    const logic [3:0] ST   = 4'b0011;
    const logic [3:0] STI  = 4'b1011;
    const logic [3:0] STR  = 4'b0111;
    const logic [3:0] TRAP = 4'b1111;
    //const logic[3:0] RTI  = 4'b0001; //no interupts
    //const logic[3:0] RESERVERD = 4'b1101; //just a nop

    logic Nf, Pf, Zf;
    logic [15:0] PC;
    logic [15:0] regs [8];

    function void set_npz(logic[15:0] alu_out);
        Nf <= alu_out[15];
        Pf <= ~(alu_out[15]);
        Zf <= (alu_out === 16'h0000);
    endfunction;

    logic [15:0] instruction;
    logic [ 3:0] opcode;
    logic [ 2:0] sr1;
    logic [ 2:0] sr2;
    logic [ 2:0] dr;
    logic        imm_sw;
    logic [ 4:0] imm5;
    logic        br_n;
    logic        br_z;
    logic        br_p;
    logic [ 2:0] base_r;
    logic        jsr_sw;
    logic [10:0] pcoffset11;
    logic [ 8:0] pcoffset9;
    logic [ 5:0] pcoffset6;
    logic [ 7:0] trapvect8;
    logic [15:0] ir;

    assign res         = new();
    assign ir          = tr.instruction;
    assign opcode      = ir[15:12];
    assign dr          = ir[11: 9];
    assign sr1         = ir[ 8: 6];
    assign sr2         = ir[ 2: 0];
    assign imm_sw      = ir[ 5];
    assign imm5        = ir[ 4: 0];
    assign br_n        = ir[11];
    assign br_z        = ir[10];
    assign br_p        = ir[ 9];
    assign base_r      = ir[ 8: 6];
    assign jsr_sw      = ir[11]; //0: jsrr, 1: jsr
    assign pcoffset6   = ir[ 5: 0];
    assign pcoffset9   = ir[ 8: 0];
    assign pcoffset11  = ir[10: 0];
    assign trapvect8   = ir[ 7: 0];

    enum integer {FETCH0=0, FETCH1=1, FETCH2=2, DECODE=3, EXECUTE=4
                    ADD0,
                    AND0,
                    NOT0,
                    TRAP0, TRAP1, TRAP2,
                    LEA0,
                    LD0, LD1, LD2
                    LDR0,   //GOES TO LD1 AFTER
                    LDI0, LDI1, LDI2, //GOES TO LD1 AFTER
                    ST0, ST1, ST2,
                    STR0, //GOES TO ST1 AFTER
                    STI0, STI1, STI2, //GOES TO ST1 AFTER
                    JSR0, JSR10, JSR11, //EITHER 0 OR 1
                    JMP0,
                    BR0, BR1, //BR1 IS OPTIONAL
                    } state;


    always @(posedge clk) begin
        if(state === FETCH0) begin
            state <= FETCH1;
            memAddrIn <= PC;
            PC <= PC + 1;
        end
        else if (state === FETCH1) begin
            state <= FETCH2;
            instruction <= memDataIn;
        end
        else if (state === FETCH2) begin
            state <= DECODE;
        end
        else if (state === DECODE) begin
            state <= EXECUTE;
            ////////////////////////////////////////////////////////////
            //Decode state;
            if(opcode === ADD) begin
                state <= ADD0;
            end
            else if(opcode === AND) begin
                state <= AND0;
            end
            else if(opcode === NOT) begin
                state <= NOT0;
            end
            else if(opcode === BR) begin
                state <= BR0;
            end
            else if(opcode === JMP) begin //also RET
                state <= JMP0;
            end
            else if(opcode === JSR) begin //aslo JSRR
                state <= JSR0;
            end
            else if(opcode === LD) begin
                state <= LD0;
            end
            else if(opcode === LDI) begin
                state <= LDI0;
            end
            else if(opcode === LDR) begin
                state <= LDR0;
            end
            else if(opcode === LEA) begin
                state <= LEA0;
            end
            else if(opcode === ST) begin
                state <= ST0;
            end
            else if(opcode === STI) begin
                state <= STI0;
            end
            else if(opcode === STR) begin
                state <= STR0;
            end
            else if(opcode === TRAP) begin
                state <= TRAP0;
            end
            else begin //NOP
                state <= FETCH0;
            end
            ///////////////////////////////////////////////////////////
        end
        ///////////////////////////////////////////////////////////////
        //FIRST EXECUTE STAGE
        else if(state === ADD0) begin
            state <= FETCH0;
            if(imm_sw) begin
                regs[dr] <= regs[sr1] + imm5;
                set_npz(regs[sr1] + imm5);
            end
            else begin
                regs[dr] <= regs[sr1] + regs[sr2];
                set_npz(regs[sr1] + regs[sr2]);
            end
        end
        else if(state === AND0) begin
            state <= FETCH0;
            if(imm_sw) begin
                regs[dr] <= regs[sr1] & imm5;
                set_npz(regs[sr1] + regs[sr2]);
            end
            else begin
                regs[dr] <= regs[sr1] & regs[sr2];
                set_npz(regs[sr1] + regs[sr2]);
            end
        end
        else if(state === NOT0) begin
            state <= FETCH0;
            regs[dr] = ~regs[sr1];
            set_npz(~regs[sr1]);
        end
        else if(state === BR0) begin
            if((br_n & Nf) || (br_p & Pf) || (br_z & Zf)) begin
                state <= BR1;
            end
            else begin
                state <= FETCH0;
            end;
        end
        else if(state === JMP0) begin //also RET
            state <= FETCH0;
            PC <= PC + pcoffset9;
        end
        else if(state === JSR0) begin //aslo JSRR
            if(jsr_sw) begin
                state <= JSR11;
            end
            else begin
                state <= JSR10;
            end
        end
        else if(state === LD0) begin
            state <= LD1;
            memAddrIn <= PC + pcoffset9;
        end
        else if(state === LDI0) begin
            state <= LDI1;
            memAddrIn <= PC + pcoffset9;
        end
        else if(state === LDR0) begin
            state <= LD1;
            memAddrIn <= base_r + pcoffset6;
        end
        else if(state === LEA0) begin
            state <= FETCH0;
            regs[dr] <= PC + pcoffset9;
            set_npz(PC + pcoffset9);
        end
        else if(state === ST0) begin
            state <= ST1;
            memAddrIn <= PC + pcoffset9;
        end
        else if(state === STI0) begin
            state <= STI1;
            memAddrIn <= PC + pcoffset9;
        end
        else if(state === STR0) begin
            state <= ST1;
            memAddrIn <= regs[base_r] + pcoffset6;
        end
        else if(state === TRAP0) begin
            state <= TRAP1;
            memAddrIn <= trapvect8;
        end
        ///////////////////////////////////////////////////////////////
        //SECOND EXECUTE STAGE
        else if(state === BR1) begin
            state <= FETCH0;
            PC = PC + pcoffset9;
        end
        else if(state === JSR10) begin //aslo JSRR
            state <= FETCH0;
            PC <= base_r;
            regs[7] <= PC;
        end
        else if(state === JSR11) begin //aslo JSRR
            state <= FETCH0;
            PC <= PC + pcoffset11;
            regs[7] <= PC;
        end
        else if(state === LD1) begin
            state <= LD2;
            regs[dr] <= memDataIn;
            set_npz(memDataIn);
        end
        else if(state === LDI1) begin
            state <= LDI2;
            memAddrIn <= memDataOut;
        end
        else if(state === ST1) begin
            state <= ST2;
            memDataOut <= regs[sr1];
        end
        else if(state === STI1) begin
            state <= STI2;
            memAddrin <= memDataOut;
        end
        else if(state === TRAP1) begin
            state <= TRAP2;
            PC <= memDataIn;
        end
        //////////////////////////////////////////////////////////////
        //THIRD EXECUTE STATE
        else if(state === LD2) begin
            state <= FETCH0;
            //done already?
        end
        else if(state === LDI2) begin
            state <= LD1;
            //done already?
        end
        else if(state === ST2) begin
            state <= FETCH0;
            //done already?
        end
        else if(state === STI2) begin
            state <= ST1;
            //done already?
        end
        else if(state === TRAP2) begin
            state <= FETCH0;
            //done already?
        end
        else begin //NOP
            state <= FETCH0;
        end
    end
endmodule
