module risv_top (
    input logic clk,
    input logic rst,
    output logic [31:0]pc,
    output logic reg_write,
    output logic [4:0]rd,
    output logic [31:0]write_back,
    output logic mem_write,
    output logic [31:0]mem_addr,
    output logic [31:0]mem_write_data,
    output logic [31:0]pc_next
);

    //Signal Declaration
    logic [31:0]pc_inc;

    logic [31:0]pc_target;

    logic [31:0]instruction;

    logic funct7;
    logic [2:0]funct3;
    logic [6:0]opcode;
    logic [1:0]reg_back;
    logic [2:0]imm_sel;
    logic src_a_sel; 
    logic src_b_sel;
    logic [3:0]alu_control;
    logic mem_read;
    logic [1:0]pc_sel;

    logic [4:0]rs1;
    logic [4:0]rs2;
    logic [31:0]rs1_data;
    logic [31:0]rs2_data;

    logic [31:0]imm_ext;

    logic [31:0]src_a;

    logic [31:0]src_b;

    logic [31:0]result;
    logic zero;

    logic [31:0]mem_read_data;

    assign funct7 = instruction[30];
    assign funct3 = instruction[14:12];
    assign opcode = instruction[6:0];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7];
    assign mem_addr = result;
    assign mem_write_data = rs2_data;

    //DUT Instantiation
    program_counter dut_pc(
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc)
    );

    instruction_memory dut_instruction_memory(
        .read_addr(pc),
        .instruction(instruction)
    );

    control_unit dut_control_unit(
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
        .pc_sel(pc_sel)
    );

    register_file dut_register_file(
        .reg_write(reg_write),
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_back),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    immediate_generator dut_immediate_generator(
        .imm_sel(imm_sel),
        .instr(instruction),
        .imm_ext(imm_ext)
    );

    alu_src_a_mux dut_alu_src_a_mux(
        .src_a_sel(src_a_sel),
        .reg_data(rs1_data),
        .pc_data(pc),
        .src_a(src_a)
    );

    alu_src_b_mux dut_alu_src_b_mux(
        .src_b_sel(src_b_sel),
        .reg_data(rs2_data),
        .imm_data(imm_ext),
        .src_b(src_b)
    );
    
    alu dut_alu(
        .alu_control(alu_control),
        .a(src_a),
        .b(src_b),
        .result(result),
        .zero(zero)
    );

    data_memory dut_data_memory(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .funct3(funct3),
        .addr(result),
        .write_data(rs2_data),
        .read_data(mem_read_data)
    );

    write_back_mux dut_write_back_mux(
        .reg_back(reg_back),
        .alu_result(result),
        .data_memory(mem_read_data),
        .pc_adder(pc_inc),
        .imm(imm_ext),
        .write_back(write_back)
    );

    pc_adder dut_pc_adder(
        .pc(pc),
        .pc_inc(pc_inc)
    );

    pc_imm dut_pc_imm(
        .pc_sel(pc_sel),
        .rs1_data(rs1_data),
        .pc(pc),
        .imm(imm_ext),
        .pc_target(pc_target)
    );

    branch_unit dut_branch_unit(
        .pc_sel(pc_sel),
        .zero(zero),
        .funct3(funct3),
        .pc_inc(pc_inc),
        .pc_target(pc_target),
        .pc_next(pc_next)
    );
endmodule