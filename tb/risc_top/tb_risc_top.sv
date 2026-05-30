module tb_risc_top;

    // =====================================================
    // Counters
    // =====================================================
    integer pass_count = 0;
    integer fail_count = 0;

    // =====================================================
    // Clock / Reset
    // =====================================================
    logic clk;
    logic rstn;

    // =====================================================
    // DUT
    // =====================================================
    risc_top dut (
        .clk  (clk),
        .rstn (rstn)
    );

    // =====================================================
    // Clock Generation
    // =====================================================
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // =====================================================
    // Check Register Task
    // =====================================================
    task automatic check_reg;
        input [4:0] reg_num;
        input [31:0] expected;
        input string name;

        begin
            if(dut.dut_register_file.registers[reg_num] === expected)
            begin
                $display(
                    "PASS [%s] x%0d = 0x%08h",
                    name,
                    reg_num,
                    expected
                );

                pass_count = pass_count + 1;
            end
            else
            begin
                $display(
                    "FAIL [%s] x%0d expected=0x%08h got=0x%08h",
                    name,
                    reg_num,
                    expected,
                    dut.dut_register_file.registers[reg_num]
                );

                fail_count = fail_count + 1;
            end
        end
    endtask

    // =====================================================
    // Main Test
    // =====================================================
    initial begin

        $display("");
        $display("========================================");
        $display("      RV32I CPU INTEGRATION TEST");
        $display("========================================");
        $display("");

        //------------------------------------------
        // Reset
        //------------------------------------------
        rstn = 1'b0;

        repeat(3)
            @(posedge clk);

        rstn = 1'b1;

        //------------------------------------------
        // Wait CPU execute program.dat
        //------------------------------------------
        repeat(50)
            @(posedge clk);

        //------------------------------------------
        // Check Registers
        //------------------------------------------

        check_reg(1 , 32'd5  , "x1");
        check_reg(2 , 32'd3  , "x2");
        check_reg(3 , 32'd8  , "x3");
        check_reg(4 , 32'd2  , "x4");
        check_reg(5 , 32'd1  , "x5");
        check_reg(6 , 32'd7  , "x6");
        check_reg(7 , 32'd6  , "x7");
        check_reg(8 , 32'd1  , "x8");
        check_reg(9 , 32'd8  , "x9");
        check_reg(10, 32'd42 , "x10");

        //------------------------------------------
        // Summary
        //------------------------------------------

        $display("");
        $display("========================================");
        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);
        $display("========================================");

        if(fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TEST FAILED");

        $display("========================================");
        $display("");

        $finish;
    end

    // =====================================================
    // Timeout
    // =====================================================
    initial begin
        #100000;

        $display("");
        $display("TIMEOUT");
        $display("");

        $finish;
    end

endmodule




