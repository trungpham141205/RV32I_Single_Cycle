module tb_alu ;
    
    //0. Counters
    int pass_count = 0;
    int fail_count = 0;

    //1. Signal Declaration
    logic [3:0]alu_control;
    logic [31:0]a;
    logic [31:0]b;
    logic [31:0]result;
    logic zero;

    //2. DUT Instantiation
    alu dut(
        .alu_control(alu_control),
        .a(a),
        .b(b),
        .result(result),
        .zero(zero)
    );

    //3. Helper Functions
    function automatic logic [31:0]calc_alu_result(input logic [3:0]alu_control, input logic [31:0]a, input logic[31:0]b);
        case (alu_control)
            4'b0000: return a + b;
            4'b0001: return a - b;
            4'b0010: return a << b[4:0];
            4'b0011: return ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            4'b0100: return ($unsigned(a) < $unsigned(b)) ? 32'b1 : 32'b0;
            4'b0101: return a ^ b;
            4'b0110: return a >> b[4:0];
            4'b0111: return $signed(a) >>> b[4:0];
            4'b1000: return a | b;
            4'b1001: return a & b;
            default: return 32'h00000000;
        endcase
    endfunction

    function automatic logic calc_alu_zero(input logic [31:0]result);
        return ((result ==  32'h00000000) ? 1'b1 : 1'b0);
    endfunction

    //4. Task: Apply and Check
    task apply_and_check(
        input logic [3:0]i_alu_control,
        input logic [31:0]i_a,
        input logic [31:0]i_b
    );

        logic [31:0]result_expected;
        logic zero_expected;
        alu_control = i_alu_control;
        a = i_a;
        b = i_b;
        result_expected = calc_alu_result(i_alu_control, i_a, i_b);
        zero_expected = calc_alu_zero(result_expected);
        #10;

        if(result == result_expected && zero == zero_expected) begin
            pass_count++;
            $display("PASS | alu_control = %h | a = %h | b = %h | result = %h | zero = %h", alu_control, a, b, result, zero);
        end
        else begin
            fail_count++;
            $display("FAIL | alu_control = %h | a = %h | b = %h | result_expected = %h | zero_expected = %h | result_got = %h | zero_got = %h", alu_control, a, b, result_expected, zero_expected, result, zero);
        end

    endtask

    //5. Initial Block
    initial begin
        apply_and_check(4'b0000, 32'h0320C680, 32'h1A2B3C4D);

        apply_and_check(4'b0000, 32'hFFFFFFFF, 32'hFFFFFFFF);

        apply_and_check(4'b0001, 32'h00000000, 32'h00000000);

        apply_and_check(4'b0001, 32'hF4E328AD, 32'h4CE905AA);

        apply_and_check(4'b0010, 32'h00000001, 32'h00000005);

        apply_and_check(4'b0011, 32'hFFFFFFFF, 32'h00000000);

        apply_and_check(4'b0011, 32'hCCCCCCCC, 32'hDDDDDDDD);

        apply_and_check(4'b0100, 32'hFFFFFFFF, 32'h00000001);

        apply_and_check(4'b0101, 32'hAAAAAAAA, 32'hAAAAAAAA);

        apply_and_check(4'b0110, 32'h80000000, 32'h00000001);

        apply_and_check(4'b0111, 32'h80000000, 32'h00000001);

        apply_and_check(4'b1000, 32'hF0F0F0F0, 32'h0F0F0F0F);

        apply_and_check(4'b1001, 32'hFFFFFFFF, 32'h0F0F0F0F);

        $display("Result: %0d PASSED, %0d FAILED", pass_count, fail_count);

        $finish;
    end

endmodule