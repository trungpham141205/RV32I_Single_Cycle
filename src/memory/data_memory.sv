module data_memory (
    input logic clk,
    input logic mem_read,
    input logic mem_write,
    input logic [2:0]funct3,
    input logic [31:0]addr,
    input logic [31:0]write_data,
    output logic [31:0]read_data
);
    logic [31:0]data_mem [0:63];
    logic [31:0]word;

    assign word = data_mem[addr[7:2]];

    always_comb begin
        if(mem_read) begin
            case (funct3)
                3'b000: begin
                    case (addr[1:0])
                        2'b00: read_data = {{24{word[7]}}, word[7:0]};
                        2'b01: read_data = {{24{word[15]}}, word[15:8]};
                        2'b10: read_data = {{24{word[23]}}, word[23:16]};
                        2'b11: read_data = {{24{word[31]}}, word[31:24]}; 
                        default: read_data = 32'b0;
                    endcase
                end 

                3'b001: begin
                    case (addr[1])
                        1'b0: read_data = {{16{word[15]}}, word[15:0]};
                        1'b1: read_data = {{16{word[31]}}, word[31:16]}; 
                        default: read_data = 32'b0;
                    endcase
                end

                3'b010: begin
                    read_data = word;
                end

                3'b100: begin
                    case (addr[1:0])
                        2'b00: read_data = {24'b0, word[7:0]};
                        2'b01: read_data = {24'b0, word[15:8]};
                        2'b10: read_data = {24'b0, word[23:16]};
                        2'b11: read_data = {24'b0, word[31:24]}; 
                        default: read_data = 32'b0;
                    endcase
                end

                3'b101: begin
                    case (addr[1])
                        1'b0: read_data = {16'b0, word[15:0]};
                        1'b1: read_data = {16'b0, word[31:16]}; 
                        default: read_data = 32'b0;
                    endcase
                end

                default: read_data = 32'b0;
            endcase
        end

        else begin
            read_data = 32'b0;
        end
    end

    always_ff @(posedge clk) begin 
        if(mem_write) begin
            case (funct3)
                3'b000: begin
                    case (addr[1:0])
                        2'b00: data_mem[addr[7:2]][7:0] <= write_data[7:0];
                        2'b01: data_mem[addr[7:2]][15:8] <= write_data[7:0];
                        2'b10: data_mem[addr[7:2]][23:16] <= write_data[7:0];
                        2'b11: data_mem[addr[7:2]][31:24] <= write_data[7:0];
                        default: data_mem[addr[7:2]] <= data_mem[addr[7:2]];
                    endcase
                end 

                3'b001: begin
                    case (addr[1])
                        1'b0: data_mem[addr[7:2]][15:0] <= write_data[15:0];
                        1'b1: data_mem[addr[7:2]][31:16] <= write_data[15:0];
                        default: data_mem[addr[7:2]] <= data_mem[addr[7:2]];
                    endcase
                end

                3'b010: begin
                    data_mem[addr[7:2]] <= write_data;
                end

                default: data_mem[addr[7:2]] <= data_mem[addr[7:2]];

            endcase
        end

        else begin
            data_mem[addr[7:2]] <= data_mem[addr[7:2]];
        end
    end

endmodule