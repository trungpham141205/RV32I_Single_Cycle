module tb_program_counter;

    //0. Counters
    int pass_count = 0;
    int fail_count = 0;

    //1. Signal Declaration
    logic clk;
    logic rst;
    logic [31:0]pc_next;
    logic [31:0]pc;

    //2. DUT Instantiation
    program_counter dut(
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc)
    );

    //3. Clock Generation
    initial clk = 0;
    always #5 clk = ~clk;


    //4. Task: Next pc 
    task next_pc(
        input logic [31:0]i_pc_next
    );

        rst = 1'b0;        
        pc_next = i_pc_next;
        @(posedge clk);   
        #1;
        
    endtask 

    //5. Task: Check
    task check(
        input logic [31:0]i_expected_pc
    );

        #10;
        if(pc == i_expected_pc) begin
            pass_count++;
            $display("PASS | pc_next = %h | pc = %h", pc_next, pc);
        end
        else begin
            fail_count++;
            $display("FAIL | pc_next = %h | expected = %h | got = %h", pc_next, i_expected_pc, pc);
        end

    endtask

    //6. Initial Block
    initial begin
        rst = 1'b1;
        pc_next = 32'h0;
        @(posedge clk);
        #1;

        // Test 1: sau reset pc = 0
        check(32'h00000000);

        // Test 2: load pc_next
        next_pc(32'h00000004);
        check(32'h00000004);

        // Test 3: reset giữa chừng
        next_pc(32'h00001000);
        rst = 1'b1;
        @(posedge clk);
        #1;
        check(32'h00000000);

        $display("Result: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $finish;
    end

endmodule