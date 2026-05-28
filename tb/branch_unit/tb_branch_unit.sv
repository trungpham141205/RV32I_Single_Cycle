module tb_branch_unit;

    //0. Counters
    int pass_count = 0;
    int fail_count = 0;

    //1. Signal Declaration
    logic [1:0]pc_sel;
    logic zero;
    logic [2:0]funct3;
    logic [31:0]pc_inc;
    logic [31:0]pc_target;
    logic [31:0]pc_next;

    //2. DUT Instantiation
    branch_unit dut(
        .pc_sel(pc_sel),
        .zero(zero),
        .funct3(funct3),
        .pc_inc(pc_inc),
        .pc_target(pc_target),
        .pc_next(pc_next)
    );

    //3. Coverage
    //Covergroup 1: Branch mode (pc_sel == 00)
    covergroup cg_branch_mode @(pc_sel, zero, funct3);
        cp_funct3: coverpoint funct3{
            bins beq = {3'b000};
            bins bne = {3'b001};
            bins blt = {3'b100};
            bins bge = {3'b101};
            bins bltu = {3'b110};
            bins bgeu = {3'b111};
            // Others funct3 is illegal -> ignore
            ignore_bins others = default;
        }

        cp_zero: coverpoint zero{
            bins zero_0 = {1'b0};
            bins zero_1 = {1'b1};
        }

        //Cross: 6 funct3 x 2 zero = 12 bins
        cx_branch: cross cp_funct3, cp_zero;
    endgroup

    //Covergroup 2: Jump/Default mode (pc_sel != 00)
    covergroup cg_jump_mode @(pc_sel);
        cp_pc_sel: coverpoint pc_sel {
            bins branch = {2'b00};
            bins jal = {2'b01};
            bins jalr = {2'b10};
            bins default_ = {2'b11};
        };
    endgroup

    cg_branch_mode cg_branch = new();
    cg_jump_mode cg_jump = new();
    
    //4. Helper Function
    function automatic logic [31:0]calc_pc_next(
        input logic [1:0]i_pc_sel,
        input logic i_zero,
        input logic [2:0]i_funct3,
        input logic [31:0]i_pc_inc,
        input logic [31:0]i_pc_target
    );

        case(i_pc_sel)
            2'b00: begin
                case (i_funct3)
                    3'b000,
                    3'b101,
                    3'b111: return i_zero ? i_pc_target : i_pc_inc;

                    3'b001,
                    3'b100,
                    3'b110: return i_zero ? i_pc_inc : i_pc_target;

                    default:  return i_pc_inc;
                endcase
            end

            2'b01,
            2'b10: return i_pc_target;
            2'b11: return i_pc_inc;
            default: return i_pc_inc;
        endcase

    endfunction

    //5. Task: Apply and Check
    task  apply_and_check(
        input logic [1:0]i_pc_sel,
        input logic i_zero,
        input logic [2:0]i_funct3,
        input logic [31:0]i_pc_inc,
        input logic [31:0]i_pc_target
    );
        
        logic [31:0]i_expected;

        //Drive inputs
        pc_sel = i_pc_sel;
        zero = i_zero;
        funct3 = i_funct3;
        pc_inc = i_pc_inc;
        pc_target = i_pc_target;
        #10;

        i_expected = calc_pc_next(i_pc_sel, i_zero, i_funct3, i_pc_inc, ic_pc_target);

        //Check
        if(pc_next == i_expected) begin
            pass_count++;
            $display("PASS | pc_sel = %b | zero = %b | funct3 = %b | pc_next =%h", i_pc_sel, i_zero, i_funct3, pc_next);
        end
        else begin
            fail_count++;
            $display("FAIL | pc_sel = %b | zero = %b | funct3 = %b | expected = %h | got = %h", i_pc_sel, i_zero, i_funct3, i_expected, pc_next)
        end

    endtask //

endmodule