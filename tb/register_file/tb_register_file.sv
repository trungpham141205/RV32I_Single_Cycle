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
            $display("PASS | rs1[%0d] = %h | rs2[%0d] = %h",
                     i_rs1, rs1_data, i_rs2, rs2_data);
        end
        else begin
            fail_count++;
            $display("FAIL | rs1[%0d] expected=%h got=%h | rs2[%0d] expected=%h got=%h",
                     i_rs1, i_expected_rs1, rs1_data,
                     i_rs2, i_expected_rs2, rs2_data);
        end
    endtask

    //6. Initial Block
    initial begin
        // Khoi tao
        reg_write  = 0;
        rd         = 0;
        write_data = 0;
        rs1        = 0;
        rs2        = 0;
        @(posedge clk); #1;

        // Test 1: x0 luon bang 0, khong the ghi
        write_reg(5'd0, 32'hDEADBEEF);
        read_and_check(5'd0, 32'h0, 5'd0, 32'h0);

        // Test 2: Ghi vao x1, doc lai
        write_reg(5'd1, 32'hAABBCCDD);
        read_and_check(5'd1, 32'hAABBCCDD, 5'd0, 32'h0);

        // Test 3: Ghi vao x2, doc ca x1 va x2 cung luc
        write_reg(5'd2, 32'h12345678);
        read_and_check(5'd1, 32'hAABBCCDD, 5'd2, 32'h12345678);

        // Test 4: Ghi de x1, kiem tra gia tri moi
        write_reg(5'd1, 32'h11111111);
        read_and_check(5'd1, 32'h11111111, 5'd2, 32'h12345678);

        // Test 5: reg_write=0 -> khong ghi duoc
        reg_write  = 1'b0;
        rd         = 5'd3;
        write_data = 32'hFFFFFFFF;
        @(posedge clk); #1;
        read_and_check(5'd3, 32'hx, 5'd0, 32'h0);

        // Test 6: rs1 == rs2 (doc cung 1 reg tren 2 port)
        write_reg(5'd5, 32'hCAFEBABE);
        read_and_check(5'd5, 32'hCAFEBABE, 5'd5, 32'hCAFEBABE);

        // Test 7: Ghi x31 (reg cuoi cung)
        write_reg(5'd31, 32'hFEDCBA98);
        read_and_check(5'd31, 32'hFEDCBA98, 5'd1, 32'h11111111);

        $display("\nResult: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $finish;
    end

endmodule
