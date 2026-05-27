module instruction_memory (
    input logic [31:0]read_addr,
    output logic [31:0]instruction
);
    
    logic [31:0]memory [0:31];

    initial begin
     	$readmemh("program.hex", memory);
    end

    always_comb begin
        instruction = memory[read_addr[7:2]];
    end

endmodule