module tb_alu_src_a_mux;

    //0. Counters
    int pass_count = 0;
    int fail_count = 0;

    //1. Signal Declaration
    logic src_a_sel;
    logic [31:0]reg_data;
    logic [31:0]pc_data;
    logic [31:0]src_a;

    //2. DUT Instantiation
    alu_src_a_mux dut(
        .src_a_sel(src_a_sel),
        .reg_data(reg_data),
        .pc_data(pc_data),
        .src_a(src_a)
    );

    //3. Task: Apply and Check
    task apply_and_check(
        input logic i_src_a_sel,
        input logic [31:0]i_reg_data,
        input logic [31:0]i_pc_data
    );

        src_a_sel = i_src_a_sel;
        reg_data = i_reg_data;
        pc_data = i_pc_data;
        #10;

        case (src_a_sel)
            1'b0: begin
                if(src_a == i_reg_data) begin
                    pass_count++;
                    $display("PASS | src_a_sel = %h | reg_data = %h | pc_data = %h | src_a = %h", 
                                     src_a_sel, reg_data, pc_data, src_a);
                end
                else begin
                    fail_count++;
                    $display("FAIl | src_a_sel = %h | reg_data = %h | pc_data = %h | expected = %h | got = %h", 
                                     src_a_sel, reg_data, pc_data, i_reg_data, src_a);
                end
            end 

            1'b1: begin
                if(src_a == i_pc_data) begin
                    pass_count++;
                    $display("PASS | src_a_sel = %h | reg_data = %h | pc_data = %h | src_a = %h", 
                                     src_a_sel, reg_data, pc_data, src_a);
                end
                else begin
                    fail_count++;
                    $display("FAIl | src_a_sel = %h | reg_data = %h | pc_data = %h | expected = %h | got = %h", 
                                     src_a_sel, reg_data, pc_data, i_pc_data, src_a);
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