module program_counter (
    input logic clk,
    input logic rstn,    
    input logic [31:0]pc_next,
    output logic [31:0]pc
);
    
    always_ff @(posedge clk) begin
        if(!rstn) begin
            pc <= 32'h00000000;
        end
        else begin
            pc <= pc_next;
        end
    end

endmodule