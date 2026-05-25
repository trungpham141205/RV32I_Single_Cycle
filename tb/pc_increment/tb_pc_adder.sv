module tb_pc_adder;

    //0. Counters   
    int pass_count = 0;
    int fail_count = 0;

    //1. Signal Declaration
    logic [31:0]pc;
    logic [31:0]pc_inc;

    //2. DUT Instantiation
    pc_adder dut(
        .pc(pc),
        .pc_inc(pc_inc)
    );

    //3. Task: Apply and Check
    task apply_and_check(
        input logic [31:0]i_pc,
        input logic [31:0]i_expected
    );
        pc = i_pc;
        #10;

        if(pc_inc == i_expected) begin
            pass_count++;
            $display("PASS | pc = %h | pc_inc = %h", pc, pc_inc);
        end
        else begin
            fail_count++;
            $display("FAIL | pc = %h | expected = %h | got = %h", pc, i_expected, pc_inc);
        end
    endtask

    //4. Initial Block
    initial begin
        //Test case 1
        apply_and_check(32'h00000000, 32'h00000004);

        //Test case 2
        apply_and_check(32'h00000004, 32'h00000008);

        //Test case 3
        apply_and_check(32'h00001000, 32'h00001004);

        //Test case 4
        apply_and_check(32'hFFFFFFFC, 32'h00000000);

        //Test case 4
        apply_and_check(32'hFFFFFFF8, 32'hFFFFFFFC);

        $display("Result: %0d PASSED, %0d FAILED", pass_count, fail_count);

        $finish;
    end

endmodule