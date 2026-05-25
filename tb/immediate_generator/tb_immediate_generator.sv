module tb_immediate_generator;
    
    //0. Counters
    int pass_count = 0;
    int fail_count = 0;

    //1. Signal Declaration
    logic [2:0]imm_sel;
    logic [31:0]instr;
    logic [31:0]imm_ext;

    //2. DUT Instantiation
    immediate_generator dut(
        .imm_sel(imm_sel),
        .instr(instr),
        .imm_ext(imm_ext)
    );

    //3.Helper Functions
    function automatic logic [31:0]calc_imm(input logic [2:0]imm_sel, input logic [31:0]instr);
        case (imm_sel)
            //U-Type
            3'b000:  return {instr[31:12], 12'b0};

            //J-Type
            3'b001:  return {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; 

            //B-Type
            3'b010:  return {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

            //I-Type
            3'b011:  return {{20{instr[31]}}, instr[31:20]};

            //S-Type
            3'b100:  return {{20{instr[31]}}, instr[31:25], instr[11:7]};

            //I-Type (Shift Amount)
            3'b101:  return {27'b0, instr[24:20]};

            default:  return 32'h00000000;
        endcase
    endfunction

    //4. Task: Apply and Check
    task apply_and_check(
        input logic [2:0]i_imm_sel,
        input logic [31:0]i_instr
    );
        logic [31:0]i_expected;
        imm_sel = i_imm_sel;
        instr = i_instr;
        i_expected = calc_imm(i_imm_sel, i_instr);
        #10;

        if(imm_ext == i_expected) begin
            pass_count++;
            $display("PASS | imm_sel = %h | instr = %h | imm_ext = %h", imm_sel, instr, imm_ext);
        end
        else begin
            fail_count++;
            $display("FAIL | imm_sel = %h | instr = %h | expected = %h | got = %h", imm_sel, instr, i_expected, imm_ext);
        end
        
    endtask 

    //5. Initial Block
    initial begin
        apply_and_check(3'b000, 32'h12345637);
        
        apply_and_check(3'b001, 32'h004000EF);
        
        apply_and_check(3'b010, 32'hFE208CE3);
        
        apply_and_check(3'b011, 32'hFFF10113);
        
        apply_and_check(3'b100, 32'h00A12423);
        
        apply_and_check(3'b101, 32'h00309093);

        $display("Result: %0d PASSED, %0d FAILED", pass_count, fail_count);

        $finish;
    end

endmodule
