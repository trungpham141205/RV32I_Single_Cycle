module tb_program_counter;

    //0. Counters
    int pass_count = 0;
    int fail_count = 0;

    //1. Signal Declaration
    logic clk, rst;
    logic [31:0]pc_next;
    logic [31:0]pc;

    //2. DUT Instantiation
    program_counter dut(
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc)
    );

    //3. Task: Apply and Check
    task apply_and_check(
        input logic [31:0]stimulus,
        input logic [31:0]expected
    );
        
    endtask 

endmodule