module tb_register_file;
    
    //0. Counters
    int pass_count = 0;
    int fail_count = 0;

    //1. Signal Declaration
    logic clk;
    logic reg_write;
    logic [4:0]rs1;
    logic [4:0]rs2;
    logic [4:0]rd;
    logic [31:0]write_data;
    logic [31:0]rs1_data;
    logic [31:0]rs2_data;

    //2. DUT Instantiation
    register_file dut(
        .clk(clk),
        .reg_write(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    //3. Clock Generation   
    initial clk = 0;
    always #5 clk = ~clk;

    //4. Task: Write Reg
    task write_reg(
        input logic [4:0]i_rd,
        input logic [31:0]i_write_data
    );

        reg_write = 1'b1;
        rd = i_rd;
        write_data = i_write_data;
        @(posedge clk);
        #1;
        reg_write = 1'b0;
        
    endtask 

    //5. Task: Read and Check
    task read_and_check(
        input logic [4:0]i_rs1,
        input logic [31:0]i_expected_rs1,
        input logic [4:0]i_rs2,
        input logic [31:0]i_expected_rs2
    );

        rs1 = i_rs1;
        rs2 = i_rs2;
        #10;

        if(rs1_data == i_expected_rs1 && rs2_data == i_expected_rs2) begin
            pass_count++;
            $display("PASS | rs1[%0d] = %h | rs2[%0d] = %h", i_rs1, rs1_data, i_rs2, rs2_data);
        end
        else begin
            fail_count++;
            $display("FAIL | rs1[%0d] expected = %h got = %h | rs2[%0d] expected = %h got = %h", i_rs1, i_expected_rs1, rs1_data, i_rs2, i_expected_rs2, rs2_data);
        end

    endtask

    //6. Task: Reset
    task do_reset();
        rst = 1'b1;
        @(posedge clk);
        #1;
        rst = 1'b0;
    endtask

    //7. Initial Block
    initial begin
        pc_next = 32'h0;
        do_reset();  // thay cho 3 dòng rst=1, @posedge, #1

        // Test 1
        check(32'h00000000);

        // Test 2
        next_pc(32'h00000004);
        check(32'h00000004);

        // Test 3
        next_pc(32'h00001000);
        do_reset();  // thay cho rst=1, @posedge, #1
        check(32'h00000000);

        $display("Result: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $finish;
    end

endmodule