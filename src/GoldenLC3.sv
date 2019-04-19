//this module is the entire LC-3 in one clock cycle.
//drive the instruction desired. run the clock once and everything will be done.
//the outputs will demonstrate what should be on the outputs to the memory. if memWE is low ignore memDataIn
//internally tracked objects:
//  PC
//  Register file
//  NPZ registers
//memDataOut must be driven on a load at the same time as instruction prior to the clock cycle.

module golden(clk, memDataIn, memAddrIn, memWE, memDataOut, instruction)
    output logic [15:0] memDataIn;
    output logic [15:0] memAddrIn;
    input  logic [15:0] instruction;
    input  logic [15:0] memDataOut;
    output logic        memWE;

    logic [15:0] PC;
    logic [15:0] regfile [7:0];
    logic Nf;
    logic Pf;
    logic Zf;

    always @(posedge clk)
    begin
        memWE = 0;
        if(instruction[15:12] == 4'b0101) begin //and
            if (instruction[5])
            begin
                regfile[instruction[11:9]] = regfile[instruction[8:6]] & instruction[4:0];
            end
            else begin
                regfile[instruction[11:9]] = regfile[instruction[8:6]] & regfile[instruction[2:0]];
            end
        end
        else if(instruction[15:12] == 4'b0001) begin //add
            if (instruction[5])
            begin
                regfile[instruction[11:9]] = regfile[instruction[8:6]] + instruction[4:0];
            end
            else begin
                regfile[instruction[11:9]] = regfile[instruction[8:6]] + regfile[instruction[2:0]];
            end
        end
        else if(instruction[15:12] == 4'b1001) begin //not
            regfile[instruction[11:9]] = ~regfile[instruction[8:6]];
        end
        else if(instruction[15:12] == 4'b0100) begin //jsr
            regfile[7] = PC + 1;
            PC = instruction[10:0] + PC;
        end
        else if(instruction[15:12] == 4'b0000) begin //Br
            if((Nf && instruction[11]) || (Pf && instruction[10]) || (Zf && instruction[9])) begin
                PC = instruction[8:0] + PC;
            end
            else begin
                PC = PC + 1;
            end
        end
        else if(instruction[15:12] == 4'b0010) begin //ld
            memAddrIn = instruction[8:0] + PC;
            regfile[instruction[11:9]] = memDataIn;
        end
        else if(instruction[15:12] == 4'b0011) begin //st
            memWE = 1;
            memAddr = PC + instruction[8:0];
            memDataIn = regfile[instruction[11:9]];
        end
        else if(instruction[15:12] == 4'b1100) begin //jmp or ret
            PC = PC regfile[instruction[8:6]];
        end
        else begin
            state <= 1;
        end
    end

endmodule