// `default_nettype none

// //a register file to be used in the lc3
// module RegFile(bus, clk, reset, regWE, DR, SR1, SR2, Rb, Ra);
//     input  [15: 0] bus;
//     output [15: 0] Rb, Ra;
//     input  clk, reset, regWE;
//     input  [ 2: 0] DR, SR1, SR2;
//     logic  [15: 0] bus;
//     logic  [15: 0] Rb, Ra;
//     logic  clk, reset, regWE;
//     logic  [ 2: 0] DR, SR1, SR2;


//     logic [15:0] regs [8];
//     initial
//     begin
//         integer i;
//         for(i = 0; i < 8; i++)
//         begin
//             regs[i] <= 0;
//         end
//     end

//     assign Rb = regs[SR2];
//     assign Ra = regs[SR1];

//     always @(posedge clk)
//     begin
//         integer i;
//         for(i = 0; i < 8; i++)
//         begin
//             if (regWE && (i == DR))
//             begin
//                 regs[i] <= bus;
//             end
//             else
//             begin
//                 regs[i] <= regs[i];
//             end
//         end

//     end


// endmodule
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



module dut(clk, reset, writeEnable, address, dataToMemory, dataFromMemory);
    input  logic        clk, reset;
    output logic        writeEnable;
    output logic [15:0] address, dataToMemory;
    input  logic [15:0] dataFromMemory;

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
    logic [15:0] PC = 0;
    logic [15:0] regs [8];

    function void set_npz(logic[15:0] alu_out);
        Nf <= alu_out[15];
        Pf <= ~(alu_out[15]) && (alu_out != 0);
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

    assign ir          = instruction;
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

    enum integer {FETCH0=0, FETCH1=1, FETCH2=2, DECODE=3, EXECUTE=4,
                    ADD0,
                    AND0,
                    NOT0,
                    TRAP0, TRAP1, TRAP2,
                    LEA0,
                    LD0, LD1, LD2,
                    LDR0,   //GOES TO LD1 AFTER
                    LDI0, LDI1, LDI2, //GOES TO LD1 AFTER
                    ST0, ST1, ST2,
                    STR0, //GOES TO ST1 AFTER
                    STI0, STI1, STI2, //GOES TO ST1 AFTER
                    JSR0, JSR10, JSR11, //EITHER 0 OR 1
                    JMP0,
                    BR0, BR1 //BR1 IS OPTIONAL
                    } state;


    always @(posedge clk) begin
        if (reset == 1) begin
            state = FETCH0;
            PC <= 0;
            Nf <= 0;
            Pf <= 0;
            Zf <= 0;
            instruction <= 0;
            dataToMemory <= 0;
            writeEnable <= 0;
            regs = {0,0,0,0,0,0,0,0};
        end
        else if(state === FETCH0) begin
            state <= FETCH1;
            address <= PC;
            PC <= PC + 1;
        end
        else if (state === FETCH1) begin
            state <= FETCH2;
            instruction <= dataToMemory;
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
            address <= PC + pcoffset9;
        end
        else if(state === LDI0) begin
            state <= LDI1;
            address <= PC + pcoffset9;
        end
        else if(state === LDR0) begin
            state <= LD1;
            address <= base_r + pcoffset6;
        end
        else if(state === LEA0) begin
            state <= FETCH0;
            regs[dr] <= PC + pcoffset9;
            set_npz(PC + pcoffset9);
        end
        else if(state === ST0) begin
            state <= ST1;
            address <= PC + pcoffset9;
        end
        else if(state === STI0) begin
            state <= STI1;
            address <= PC + pcoffset9;
        end
        else if(state === STR0) begin
            state <= ST1;
            address <= regs[base_r] + pcoffset6;
        end
        else if(state === TRAP0) begin
            state <= TRAP1;
            address <= trapvect8;
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
            regs[dr] <= dataToMemory;
            set_npz(dataToMemory);
        end
        else if(state === LDI1) begin
            state <= LDI2;
            address <= dataFromMemory;
        end
        else if(state === ST1) begin
            state <= ST2;
            dataToMemory <= regs[sr1];
            writeEnable <= 1;
        end
        else if(state === STI1) begin
            state <= STI2;
            address <= dataFromMemory;
        end
        else if(state === TRAP1) begin
            state <= TRAP2;
            PC <= dataFromMemory;
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
            writeEnable <= 0;
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


// module dut(/*ldMAR, ldMDR, */clk, reset, writeEnable, /*selMDR, */address, dataToMemory, dataFromMemory);
//     input clk, reset;
//     output writeEnable;
//     output [15:0] address, dataToMemory;
//     input [15:0] dataFromMemory;
//     logic clk, reset;
//     logic writeEnable, selMDR;
//     logic [15:0] address, dataToMemory;
//     logic [15:0] dataFromMemory;
//     //input logic ldMAR, ldMDR;
//     logic [15:0] bus;
//     logic [ 2:0] DR, SR1, SR2;
//     logic [15:0] Rb, Ra;
//     RegFile generalRegisterFile (
//         //bus, clk, reset, regWE, DR, SR1, SR2, Rb, Ra
//         .*
//     );

//     logic [15:0] instruction;
//     logic [15:0] PC = 0;
//     logic write_reg = 0;
//     logic Nf, Zf, Pf;
//     logic regWE, write_mem;
//     logic [15:0] temp;
//     //machine states are load, decode, execute. I think I can do this all in 3 clocks for simplicity.
//     //state is held in registers, memory, the pzn bits.
//     enum integer {FETCH=0, DECODE=1, EXECUTE=2} state;//0 fetch 1 decode 2 execute
//     always_ff @(posedge clk)
//     begin
//         address <= PC;
//         dataToMemory <= 0;
//         writeEnable <= 0;
//         regWE <= 0;
//         bus <= 0;
//         DR <= DR;
//         SR1 <= SR1;
//         SR2 <= SR2;
//         instruction <= instruction;
//         write_reg <= write_reg;
//         write_mem <= write_mem;
//         PC <= PC;
//         // Nf = Nf;
//         // Zf = Zf;
//         // Pf = Pf;
//         if(state == FETCH)  //fetch
//         begin
//             instruction <= dataFromMemory;
//             state <= DECODE;
//         end
//         //else if (state == 1)
//         //begin
//         //
//         //    state <= 2;
//         //end
//         else if(state == DECODE)  //decode
//         begin
//             if(instruction[15:12] == 4'b0101) begin //and
//                 write_reg <= 1;
//                 write_mem <= 0;
//                 DR <= instruction[11:9];
//                 SR1 <= instruction[8:6];
//                 SR2 <= instruction[2:0];
//                 state <= EXECUTE;
//             end
//             else if(instruction[15:12] == 4'b0001) begin //add
//                 write_reg <= 1;
//                 write_mem <= 0;
//                 DR <= instruction[11:9];
//                 SR1 <= instruction[8:6];
//                 SR2 <= instruction[2:0];
//                 state <= EXECUTE;
//             end
//             else if(instruction[15:12] == 4'b1001) begin //not
//                 write_reg <= 1;
//                 write_mem <= 0;
//                 DR <= instruction[11:9];
//                 SR1 <= instruction[8:6];
//                 SR2 <= instruction[2:0];
//                 state <= EXECUTE;
//             end
//             else if(instruction[15:12] == 4'b0100) begin //jsr
//                 regWE <= 1;
//                 write_reg <= 0;
//                 write_mem <= 0;
//                 DR <= 7;
//                 bus <= PC;
//                 PC <= PC + instruction[11:0];
//                 state <= FETCH;
//             end
//             else if(instruction[15:12] == 4'b0000) begin //Br
//                 write_reg <= 0;
//                 write_mem <= 0;
//                 if((Nf && instruction[11]) || (Pf && instruction[10]) || (Zf && instruction[9]))begin
//                     PC <= PC + instruction[8:0];
//                 end
//                 else begin
//                     PC <= PC + 1;
//                 end
//                 state <= FETCH;
//             end
//             else if(instruction[15:12] == 4'b0010) begin //ld
//                 write_reg <= 1;
//                 write_mem <= 0;
//                 DR <= instruction[11:9];
//                 address <= instruction[8:0] + PC;
//                 state <= EXECUTE;
//             end
//             else if(instruction[15:12] == 4'b0011) begin //st
//                 write_reg <= 0;
//                 write_mem <= 1;
//                 SR1 <= instruction[11:9];
//                 state <= EXECUTE;
//             end
//             else if(instruction[15:12] == 4'b1100) begin //jmp or ret
//                 write_reg <= 0;
//                 write_mem <= 0;
//                 SR1 <= instruction[8:6];
//                 state <= EXECUTE;
//             end
//             else begin
//                 state <= EXECUTE;
//             end
//         end
//         else if(state == EXECUTE)  //execute
//         begin
//             writeEnable <= write_mem;
//             regWE <= write_reg;
            
//             if(instruction[15:12] == 4'b0101) begin //and
//                 if(instruction[5]) begin
//                     bus <= Ra & instruction[4:0];
//                     //logic [15:0] temp;
//                     temp = (Ra & instruction[4:0]);
//                     Pf = ~temp[15];
//                     Nf = temp[15];
//                     Zf = temp == 0;
//                 end
//                 else begin
//                     bus <= Ra & Rb;
//                     //logic [15:0] temp;
//                     temp = (Ra & Rb);
//                     Pf = ~temp[15];
//                     Nf = temp[15];
//                     Zf = temp == 0;
//                 end
//                 PC <= PC + 1;
//             end
//             else if(instruction[15:12] == 4'b0001) begin //add
//                 if(instruction[5]) begin
//                     bus <= Ra + instruction[4:0];
//                     //logic [15:0] temp;
//                     Pf = ~temp[15];
//                     Nf = temp[15];
//                     Zf = temp == 0;
//                 end
//                 else begin
//                     bus <= Ra + Rb;
//                     ///logic[15:0] temp;
//                     temp = (Ra + Rb);
//                     Pf = ~temp[15];
//                     Nf = temp[15];
//                     Zf = temp == 0;
//                 end
//                 PC <= PC + 1;
//             end
//             else if(instruction[15:12] == 4'b1001) begin //not
//                 bus <= ~Ra;
//                 Pf = Ra[15];
//                 Nf = ~Ra[15];
//                 Zf = (~Ra) == 0;
//                 PC <= PC + 1;
//             end
//             else if(instruction[15:12] == 4'b0010) begin //ld
//                 bus <= dataFromMemory;
//                 PC <= PC + 1;
//             end
//             else if(instruction[15:12] == 4'b0011) begin //st
//                 dataToMemory <= Ra;
//                 address <= PC + instruction[8:0];
//                 PC <= PC + 1;
//             end
//             else if(instruction[15:12] == 4'b1100) begin //jmp or ret
//                 PC <= Ra;
//             end
//             else begin
//                 state <= FETCH;
//                 PC <= PC + 1;
//             end
//             state <= FETCH;
//         end
//         else begin
//             //we have a problem here
//             state <= FETCH;
//         end
//     end
// endmodule

