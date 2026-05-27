package tb_utils_pkg;

    typedef struct packed {
        logic reg_write;
        logic [1:0] reg_back;
        logic [2:0] imm_sel;
        logic src_a_sel;
        logic src_b_sel;
        logic [3:0] alu_control;
        logic mem_read;
        logic mem_write;
        logic [1:0]pc_sel;
    } control_t;

    function automatic control_t calc_control(
        input logic funct7,
        input logic [2:0]funct3,
        input logic [6:0]opcode
    );
        control_t control;
        control = '0;

        case (opcode)
            //LUI
            7'b0110111: begin
                control.reg_write = 1'b1;
                control.reg_back = 2'b11;
                control.pc_sel = 2'b11;
            end 

            //AUIPC
            7'b0010111: begin
                control.reg_write = 1'b1;
                control.src_a_sel = 1'b1;
                control.src_b_sel = 1'b1;
                control.pc_sel = 2'b11;
            end 

            //JAL
            7'b1101111: begin
                control.reg_write = 1'b1;
                control.reg_back = 2'b10;
                control.imm_sel = 3'b001;
                control.pc_sel = 2'b01;
            end

            //B-TYPE
            7'b1100011: begin

                control.imm_sel = 3'b010;
                control.pc_sel = 2'b00;

                case (funct3)
                    //BEQ, BNE
                    3'b000,
                    3'b001: control.alu_control = 4'b0001;

                    //BLT, BGE
                    3'b100,
                    3'b101: control.alu_control = 4'b0011;

                    //BLTU, BGEU
                    3'b110,
                    3'b111: control.alu_control = 4'b0100;
                  
                    default: control.alu_control = 4'b0000;
                endcase
            end

            //JALR
            7'b1100111: begin
                control.reg_write = 1'b1;
                control.reg_back = 2'b10;
                control.imm_sel = 3'b011;
                control.src_b_sel = 1'b1;
                control.pc_sel = 2'b10;
            end 
            
            //LOAD
            7'b0000011: begin
                control.reg_write = 1'b1;
                control.reg_back = 2'b01;
                control.imm_sel = 3'b011;
                control.src_b_sel = 1'b1;
                control.mem_read = 1'b1;
                control.pc_sel = 2'b11;
            end

            //I-TYPE
            7'b0010011: begin
                control.reg_write = 1'b1;
                control.src_b_sel = 1'b1;
                control.pc_sel = 2'b11;
                casez ({funct3, funct7})
                    4'b000?: begin
                        control.imm_sel = 3'b011;
                        control.alu_control = 4'b0000; 
                    end
                    4'b010?: begin
                        control.imm_sel = 3'b011;
                        control.alu_control = 4'b0100; 
                    end
                    4'b011?: begin
                        control.imm_sel = 3'b011;
                        control.alu_control = 4'b0101; 
                    end
                    4'b100?: begin
                        control.imm_sel = 3'b011;
                        control.alu_control = 4'b0110; 
                    end
                    4'b110?: begin
                        control.imm_sel = 3'b011;
                        control.alu_control = 4'b1001; 
                    end
                    4'b111?: begin
                        control.imm_sel = 3'b011;
                        control.alu_control = 4'b1010; 
                    end

                    //SLLI
                    4'b0010: begin
                        control.imm_sel = 3'b101;
                        control.alu_control = 4'b0010; 
                    end

                    //SRLI
                    4'b1010: begin
                        control.imm_sel = 3'b101;
                        control.alu_control = 4'b0110; 
                    end

                    //SRAI
                    4'b1011: begin
                        control.imm_sel = 3'b101;
                        control.alu_control = 4'b0111; 
                    end

                    default: begin
                        control.imm_sel = 3'b000;
                        control.alu_control = 4'b0000; 
                    end
                endcase
            end

            //S-TYPE
            7'b0100011: begin
                control.imm_sel = 3'b100;
                control.src_b_sel = 1'b1;
                control.mem_write = 1'b1;
                control.pc_sel = 2'b11;
            end

            //R-TYPE
            7'b0110011: begin
                control.reg_write = 1'b1;
                control.pc_sel = 2'b11;
                case ({funct3, funct7})
                    4'b0000: control.alu_control = 4'b0000;
                    4'b0001: control.alu_control = 4'b0001;
                    4'b0010: control.alu_control = 4'b0010;
                    4'b0100: control.alu_control = 4'b0011;
                    4'b0110: control.alu_control = 4'b0100;
                    4'b1000: control.alu_control = 4'b0101;
                    4'b1010: control.alu_control = 4'b0110;
                    4'b1011: control.alu_control = 4'b0111;
                    4'b1100: control.alu_control = 4'b1000;
                    4'b1110: control.alu_control = 4'b1001;
                    default: control.alu_control = 4'b0000;
                endcase
            end

            default: control = '0;
        endcase

        return control;
    endfunction

endpackage
