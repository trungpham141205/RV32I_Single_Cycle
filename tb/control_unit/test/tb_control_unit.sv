`include "../utils/tb_utils_pkg.sv"
import tb_utils_pkg::*;
module tb_control_unit;

    //0. Counters
    int pass_count = 0;
    int fail_count = 0;

    //1. Signal Declaration
    logic funct7;
    logic [2:0]funct3;
    logic [6:0]opcode;
    logic reg_write;
    logic [1:0]reg_back;
    logic [2:0]imm_sel;
    logic src_a_sel;
    logic src_b_sel;
    logic [3:0]alu_control;
    logic mem_read;
    logic mem_write;
    logic branch;
    logic jump;
    logic jump_reg;

    //2. DUT Instantiation
    control_unit dut(
        .funct7(funct7),
        .funct3(funct3),
        .opcode(opcode),
        .reg_write(reg_write),
        .reg_back(reg_back),
        .imm_sel(imm_sel),
        .src_a_sel(src_a_sel),
        .src_b_sel(src_b_sel),
        .alu_control(alu_control),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump),
        .jump_reg(jump_reg)
    );

    //3. Task: Apply and Check
    task apply_and_check(
        input logic i_funct7,
        input logic [2:0]i_funct3,
        input logic [6:0]i_opcode
    );
        
        control_t i_expected;
        funct7 = i_funct7;
        funct3 = i_funct3;
        opcode = i_opcode;
        i_expected = calc_control(i_funct7, i_funct3, i_opcode);
        #10;

        if({reg_write, reg_back, imm_sel, src_a_sel, src_b_sel, alu_control, mem_read, mem_write, branch, jump, jump_reg} == i_expected) begin
            pass_count++;
            $display("PASS | funct7 = %h | funct3 = %h | opcode = %h | result = %h", funct7, funct3, opcode, {reg_write, reg_back, imm_sel, src_a_sel, src_b_sel, alu_control, mem_read, mem_write, branch, jump, jump_reg});
        end
        else begin
            fail_count++;
            $display("FAIl | funct7 = %h | funct3 = %h | opcode = %h | expected = %h | got = %h", funct7, funct3, opcode, i_expected, {reg_write, reg_back, imm_sel, src_a_sel, src_b_sel, alu_control, mem_read, mem_write, branch, jump, jump_reg});
        end

    endtask 

    //5. Initial Block
    initial begin
    // LUI
    apply_and_check(1'b0, 3'b000, 7'b0110111);

    // AUIPC
    apply_and_check(1'b0, 3'b000, 7'b0010111);

    // JAL
    apply_and_check(1'b0, 3'b000, 7'b1101111);

    // JALR
    apply_and_check(1'b0, 3'b000, 7'b1100111);

    // LOAD
    apply_and_check(1'b0, 3'b010, 7'b0000011);

    // S-TYPE
    apply_and_check(1'b0, 3'b010, 7'b0100011);

    // B-TYPE
    apply_and_check(1'b0, 3'b000, 7'b1100011); // BEQ
    apply_and_check(1'b0, 3'b001, 7'b1100011); // BNE
    apply_and_check(1'b0, 3'b100, 7'b1100011); // BLT
    apply_and_check(1'b0, 3'b110, 7'b1100011); // BLTU

    // I-TYPE
    apply_and_check(1'b0, 3'b000, 7'b0010011); // ADDI
    apply_and_check(1'b0, 3'b001, 7'b0010011); // SLLI
    apply_and_check(1'b0, 3'b101, 7'b0010011); // SRLI
    apply_and_check(1'b1, 3'b101, 7'b0010011); // SRAI

    // R-TYPE
    apply_and_check(1'b0, 3'b000, 7'b0110011); // ADD
    apply_and_check(1'b1, 3'b000, 7'b0110011); // SUB
    apply_and_check(1'b0, 3'b101, 7'b0110011); // SRL
    apply_and_check(1'b1, 3'b101, 7'b0110011); // SRA

    $display("Result: %0d PASSED, %0d FAILED", pass_count, fail_count);
    $finish;
end
    
endmodule