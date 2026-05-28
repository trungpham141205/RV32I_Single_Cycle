module tb_risc_top;

    // =========================================================
    // 0. Counters
    // =========================================================
    int pass_count = 0;
    int fail_count = 0;

    // =========================================================
    // 1. Signal Declaration
    // =========================================================
    logic        clk;
    logic        rst;
    logic [31:0] pc;
    logic        reg_write;
    logic [4:0]  rd;
    logic [31:0] write_back;
    logic        mem_write;
    logic [31:0] mem_addr;
    logic [31:0] mem_write_data;
    logic [31:0] pc_next;

    // =========================================================
    // 2. DUT Instantiation
    // =========================================================
    risc_top dut (
        .clk           (clk),
        .rst           (rst),
        .pc            (pc),
        .reg_write     (reg_write),
        .rd            (rd),
        .write_back    (write_back),
        .mem_write     (mem_write),
        .mem_addr      (mem_addr),
        .mem_write_data(mem_write_data),
        .pc_next       (pc_next)
    );

    // =========================================================
    // 3. Clock Generation — period 10ns
    // =========================================================
    initial clk = 0;
    always #5 clk = ~clk;

    // =========================================================
    // 4. Tasks
    // =========================================================

    // Check register write: reg_write, rd, write_back
    task automatic check_reg_write(
        input logic [4:0]  i_rd,
        input logic [31:0] i_wdata,
        input string       i_name
    );
        @(negedge clk);
        if (reg_write === 1'b1 && rd === i_rd && write_back === i_wdata) begin
            $display("PASS [%s]  reg_write=1  x%0d = 0x%08h", i_name, i_rd, i_wdata);
            pass_count++;
        end else begin
            $display("FAIL [%s]  expected reg_write=1 x%0d=0x%08h",
                     i_name, i_rd, i_wdata);
            $display("           got      reg_write=%0b rd=%0d write_back=0x%08h",
                     reg_write, rd, write_back);
            fail_count++;
        end
    endtask

    // Check memory write: mem_write, addr, wdata
    task automatic check_mem_write(
        input logic [31:0] i_addr,
        input logic [31:0] i_wdata,
        input string       i_name
    );
        @(negedge clk);
        if (mem_write === 1'b1 && mem_addr === i_addr && mem_write_data === i_wdata) begin
            $display("PASS [%s]  mem_write=1  mem[0x%08h] = 0x%08h",
                     i_name, i_addr, i_wdata);
            pass_count++;
        end else begin
            $display("FAIL [%s]  expected mem_write=1 addr=0x%08h wdata=0x%08h",
                     i_name, i_addr, i_wdata);
            $display("           got      mem_write=%0b addr=0x%08h wdata=0x%08h",
                     mem_write, mem_addr, mem_write_data);
            fail_count++;
        end
    endtask

    //Check pc_next
    task automatic check_pc_next(
        input logic [31:0] i_pc_next,
        input string       i_name
    );
        @(negedge clk);
        if (pc_next === i_pc_next) begin
            $display("PASS [%s]  pc_next = 0x%08h", i_name, i_pc_next);
            pass_count++;
        end else begin
            $display("FAIL [%s]  expected pc_next=0x%08h  got 0x%08h",
                     i_name, i_pc_next, pc_next);
            fail_count++;
        end
    endtask

    task automatic skip_cycle(input string i_name);
        @(negedge clk);
        $display("SKIP [%s]", i_name);
    endtask

    // =========================================================
    // 5. Main Test
    // =========================================================
    initial begin
        $display("=== RV32I Integration Test ===\n");

        // Reset — giữ 2 cycles
        rst = 1;
        repeat(2) @(posedge clk);
        #1 rst = 0;

        // --------------------------------------------------
        // PC=0x00: addi x1, x0, 5  → x1 = 5
        check_reg_write(5'd1, 32'd5, "ADDI x1,x0,5");

        // PC=0x04: addi x2, x0, 3  → x2 = 3
        check_reg_write(5'd2, 32'd3, "ADDI x2,x0,3");

        // PC=0x08: add x3, x1, x2  → x3 = 8
        check_reg_write(5'd3, 32'd8, "ADD  x3,x1,x2");

        // PC=0x0c: sub x4, x1, x2  → x4 = 2
        check_reg_write(5'd4, 32'd2, "SUB  x4,x1,x2");

        // PC=0x10: and x5, x1, x2  → x5 = 5&3 = 1
        check_reg_write(5'd5, 32'd1, "AND  x5,x1,x2");

        // PC=0x14: or x6, x1, x2   → x6 = 5|3 = 7
        check_reg_write(5'd6, 32'd7, "OR   x6,x1,x2");

        // PC=0x18: xor x7, x1, x2  → x7 = 5^3 = 6
        check_reg_write(5'd7, 32'd6, "XOR  x7,x1,x2");

        // PC=0x1c: slt x8, x2, x1  → x8 = (3<5) = 1
        check_reg_write(5'd8, 32'd1, "SLT  x8,x2,x1");

        // PC=0x20: sw x3, 0(x0)    → mem[0] = 8
        check_mem_write(32'h0, 32'd8, "SW   x3,0(x0)");

        // PC=0x24: lw x9, 0(x0)    → x9 = 8
        check_reg_write(5'd9, 32'd8, "LW   x9,0(x0)");

        // PC=0x28: beq x1, x1, +8  → pc_next = 0x30 (branch taken)
        check_pc_next(32'h00000030, "BEQ  x1,x1,+8");

        // PC=0x2c: SKIPPED (branch taken)
        // PC=0x30: addi x10, x0, 42 → x10 = 42
        check_reg_write(5'd10, 32'd42, "ADDI x10,x0,42 (branch target)");

        // PC=0x34: jal x11, +8
        //   → x11 = PC+4 = 0x38
        //   → pc_next = 0x34+8 = 0x3c
        @(negedge clk);
        begin
            logic pass_jal;
            pass_jal = 1;
            if (reg_write !== 1'b1 || rd !== 5'd11 || write_back !== 32'h00000038) begin
                $display("FAIL [JAL x11,+8]  expected x11=0x38  got rd=%0d wb=0x%08h",
                         rd, write_back);
                pass_jal = 0;
            end
            if (pc_next !== 32'h0000003c) begin
                $display("FAIL [JAL x11,+8]  expected pc_next=0x3c  got 0x%08h", pc_next);
                pass_jal = 0;
            end
            if (pass_jal) begin
                $display("PASS [JAL x11,+8]  x11=0x38  pc_next=0x3c");
                pass_count++;
            end else fail_count++;
        end

        skip_cycle("NOP addi x0,x0,0");

        // --------------------------------------------------
        // Summary
        @(posedge clk); #1;
        $display("\n==============================================");
        $display("  TOTAL: %0d PASS  /  %0d FAIL", pass_count, fail_count);
        $display("==============================================");
        if (fail_count == 0)
            $display("  ✓ ALL TESTS PASSED");
        else
            $display("  ✗ SOME TESTS FAILED — check waveform");
        $display("==============================================\n");
        $finish;
    end


    initial begin
        #10000;
        $display("TIMEOUT — simulation exceeded limit");
        $finish;
    end

endmodule
