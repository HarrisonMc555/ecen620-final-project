`default_nettype none

//a register file to be used in the lc3
module RegFile(bus, clk, reset, regWE, DR, SR1, SR2, Rb, Ra);
    input  [15: 0] bus;
    output [15: 0] Rb, Ra;
    input  clk, reset, regWE;
    input  [ 2: 0] DR, SR1, SR2;
    logic  [15: 0] bus;
    logic  [15: 0] Rb, Ra;
    logic  clk, reset, regWE;
    logic  [ 2: 0] DR, SR1, SR2;


    logic [15:0] regs [8];
    initial
    begin
        integer i;
        for(i = 0; i < 8; i++)
        begin
            regs[i] <= 0;
        end
    end

    assign Rb = regs[SR2];
    assign Ra = regs[SR1];

    always @(posedge clk)
    begin
        integer i;
        for(i = 0; i < 8; i++)
        begin
            if (regWE && (i == DR))
            begin
                regs[i] <= bus;
            end
            else
            begin
                regs[i] <= regs[i];
            end
        end

    end


endmodule
/*
Instructions to implement:
    And 0101
    Add 0001
        and and add are one of the following
        4'opcode, 3'dr, 3'sr1, 000, 3'sr2
        4'opcode, 3'dr, 3'sr1, 1, 5'immediate

    Not 1001
        looks like this
        4'opcode, 3'dr, 3'sr, 111111
    
    Jsr 0100
        4'opcode, 1, 11'PCoffset

    Br  0000
        4'opcode, 1'n, 1'z, 1'p, 9' PCoffset

    Ld  0010
        4'opcode, 3'dr, 9'PCoffset

    St  0011
        4'opcode, 3'sr, 9'PCoffset

    Jmp 1100 (same as RET)
        4'opcode, 000, 3'BaseR, 000000 

    Ret 1100 (same as JMP)
        4'opcode, 000, 111, 000000
*/

module lc3(/*ldMAR, ldMDR, */clk, reset, memWE, /*selMDR, */memAddrIn, memDataIn, memDataOut);
    input clk, reset;
    output memWE;
    output [15:0] memAddrIn, memDataIn;
    input [15:0] memDataOut;
    logic clk, reset;
    logic memWE, selMDR;
    logic [15:0] memAddrIn, memDataIn;
    logic [15:0] memDataOut;
    //input logic ldMAR, ldMDR;
    logic [15:0] bus;
    logic [ 2:0] DR, SR1, SR2;
    logic [15:0] Rb, Ra;
    RegFile generalRegisterFile (
        //bus, clk, reset, regWE, DR, SR1, SR2, Rb, Ra
        .*
    );

    logic [15:0] instruction;
    logic [15:0] PC = 0;
    logic write_reg = 0;
    logic Nf, Zf, Pf;
    logic regWE, write_mem;
    logic [15:0] temp;
    //machine states are load, decode, execute. I think I can do this all in 3 clocks for simplicity.
    //state is held in registers, memory, the pzn bits.
    enum integer {FETCH=0, DECODE=1, EXECUTE=2} state;//0 fetch 1 decode 2 execute
    always_ff @(posedge clk)
    begin
        memAddrIn <= PC;
        memDataIn <= 0;
        memWE <= 0;
        regWE <= 0;
        bus <= 0;
        DR <= DR;
        SR1 <= SR1;
        SR2 <= SR2;
        instruction <= instruction;
        write_reg <= write_reg;
        write_mem <= write_mem;
        PC <= PC;
        // Nf = Nf;
        // Zf = Zf;
        // Pf = Pf;
        if(state == FETCH)  //fetch
        begin
            instruction <= memDataOut;
            state <= DECODE;
        end
        //else if (state == 1)
        //begin
        //
        //    state <= 2;
        //end
        else if(state == DECODE)  //decode
        begin
            if(instruction[15:12] == 4'b0101) begin //and
                write_reg <= 1;
                write_mem <= 0;
                DR <= instruction[11:9];
                SR1 <= instruction[8:6];
                SR2 <= instruction[2:0];
                state <= EXECUTE;
            end
            else if(instruction[15:12] == 4'b0001) begin //add
                write_reg <= 1;
                write_mem <= 0;
                DR <= instruction[11:9];
                SR1 <= instruction[8:6];
                SR2 <= instruction[2:0];
                state <= EXECUTE;
            end
            else if(instruction[15:12] == 4'b1001) begin //not
                write_reg <= 1;
                write_mem <= 0;
                DR <= instruction[11:9];
                SR1 <= instruction[8:6];
                SR2 <= instruction[2:0];
                state <= EXECUTE;
            end
            else if(instruction[15:12] == 4'b0100) begin //jsr
                regWE <= 1;
                write_reg <= 0;
                write_mem <= 0;
                DR <= 7;
                bus <= PC;
                PC <= PC + instruction[11:0];
                state <= FETCH;
            end
            else if(instruction[15:12] == 4'b0000) begin //Br
                write_reg <= 0;
                write_mem <= 0;
                if((Nf && instruction[11]) || (Pf && instruction[10]) || (Zf && instruction[9]))begin
                    PC <= PC + instruction[8:0];
                end
                else begin
                    PC <= PC + 1;
                end
                state <= FETCH;
            end
            else if(instruction[15:12] == 4'b0010) begin //ld
                write_reg <= 1;
                write_mem <= 0;
                DR <= instruction[11:9];
                memAddrIn <= instruction[8:0] + PC;
                state <= EXECUTE;
            end
            else if(instruction[15:12] == 4'b0011) begin //st
                write_reg <= 0;
                write_mem <= 1;
                SR1 <= instruction[11:9];
                state <= EXECUTE;
            end
            else if(instruction[15:12] == 4'b1100) begin //jmp or ret
                write_reg <= 0;
                write_mem <= 0;
                SR1 <= instruction[8:6];
                state <= EXECUTE;
            end
            else begin
                state <= EXECUTE;
            end
        end
        else if(state == EXECUTE)  //execute
        begin
            memWE <= write_mem;
            regWE <= write_reg;
            
            if(instruction[15:12] == 4'b0101) begin //and
                if(instruction[5]) begin
                    bus <= Ra & instruction[4:0];
                    //logic [15:0] temp;
                    temp = (Ra & instruction[4:0]);
                    Pf = ~temp[15];
                    Nf = temp[15];
                    Zf = temp == 0;
                end
                else begin
                    bus <= Ra & Rb;
                    //logic [15:0] temp;
                    temp = (Ra & Rb);
                    Pf = ~temp[15];
                    Nf = temp[15];
                    Zf = temp == 0;
                end
                PC <= PC + 1;
            end
            else if(instruction[15:12] == 4'b0001) begin //add
                if(instruction[5]) begin
                    bus <= Ra + instruction[4:0];
                    //logic [15:0] temp;
                    Pf = ~temp[15];
                    Nf = temp[15];
                    Zf = temp == 0;
                end
                else begin
                    bus <= Ra + Rb;
                    ///logic[15:0] temp;
                    temp = (Ra + Rb);
                    Pf = ~temp[15];
                    Nf = temp[15];
                    Zf = temp == 0;
                end
                PC <= PC + 1;
            end
            else if(instruction[15:12] == 4'b1001) begin //not
                bus <= ~Ra;
                Pf = Ra[15];
                Nf = ~Ra[15];
                Zf = (~Ra) == 0;
                PC <= PC + 1;
            end
            else if(instruction[15:12] == 4'b0010) begin //ld
                bus <= memDataOut;
                PC <= PC + 1;
            end
            else if(instruction[15:12] == 4'b0011) begin //st
                memDataIn <= Ra;
                memAddrIn <= PC + instruction[8:0];
                PC <= PC + 1;
            end
            else if(instruction[15:12] == 4'b1100) begin //jmp or ret
                PC <= Ra;
            end
            else begin
                state <= FETCH;
                PC <= PC + 1;
            end
            state <= FETCH;
        end
        else begin
            //we have a problem here
            state <= FETCH;
        end
    end
endmodule

