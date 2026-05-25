module tb_alu_src_b_mux;

    //0. Counters
    int pass_count = 0;
    int fail_count = 0;

    //1. Signal Declaration
    logic src_b_sel;
    logic [31:0]reg_data;
    logic [31:0]imm_data;
    logic [31:0]src_b;

    //2. DUT Instantiation
    alu_src_b_mux dut(
        .src_b_sel(src_b_sel),
        .reg_data(reg_data),
        .imm_data(imm_data),
        .src_b(src_b)
    );

    //3. Task: Apply and Check
    task apply_and_check(
        input logic i_src_b_sel,
        input logic [31:0]i_reg_data,
        input logic [31:0]i_imm_data
    );

        src_b_sel = i_src_b_sel;
        reg_data = i_reg_data;
        imm_data = i_imm_data;
        #10;

        case (src_b_sel)
            1'b0: begin
                if(src_b == i_reg_data) begin
                    pass_count++;
                    $display("PASS | src_b_sel = %h | reg_data = %h | imm_data = %h | src_b = %h", 
                                     src_b_sel, reg_data, imm_data, src_b);
                end
                else begin
                    fail_count++;
                    $display("FAIl | src_b_sel = %h | reg_data = %h | imm_data = %h | expected = %h | got = %h", 
                                     src_b_sel, reg_data, imm_data, i_reg_data, src_b);
                end
            end 

            1'b1: begin
                if(src_b == i_imm_data) begin
                    pass_count++;
                    $display("PASS | src_b_sel = %h | reg_data = %h | imm_data = %h | src_a = %h", 
                                     src_b_sel, reg_data, imm_data, src_b);
                end
                else begin
                    fail_count++;
                    $display("FAIl | src_b_sel = %h | reg_data = %h | imm_data = %h | expected = %h | got = %h", 
                                     src_b_sel, reg_data, imm_data, i_imm_data, src_b);
                end
            end
        endcase
        
    endtask 

    //4. Initial Block
    initial begin
        //Test case 1
        apply_and_check(0, 32'h00000000, 32'hFFFFFFFC);

        //Test case 2
        apply_and_check(1, 32'h1A2B3C4D, 32'h00001004);

        $display("Result: %0d PASSED, %0d FAILED", pass_count, fail_count);

        $finish;
    end

endmodule