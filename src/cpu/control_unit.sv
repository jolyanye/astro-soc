module control_unit (
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic funct7_5,
    output logic ALUSrc,  // 1: imm val, 0: rd2 reg val
    output logic RegWrite,
    output logic [2:0] ALUControl,
    output logic MemWrite,
    output logic ResultSrc  // store to rf - 1: memory data, 0: ALU result
);
    localparam [2:0] OP_ADD = 3'b000;
    localparam [2:0] OP_SUB = 3'b001;
    localparam [2:0] OP_AND = 3'b010;
    localparam [2:0] OP_OR  = 3'b011;

    always_comb begin
        ALUSrc = 1'b0;
        RegWrite = 1'b0;
        ALUControl = OP_ADD;
        MemWrite = 1'b0;
        ResultSrc = 1'b0;

        case (op)
            // R-Type Instructions (ADD, SUB, AND, OR)
            7'b0110011: begin
                ALUSrc = 1'b0; 
                RegWrite = 1'b1;
                MemWrite = 1'b0;
                ResultSrc = 1'b0;
                case (funct3)
                    3'b000: ALUControl = (funct7_5) ? OP_SUB : OP_ADD;
                    3'b110: ALUControl = OP_OR;
                    3'b111: ALUControl = OP_AND;
                    default: ALUControl = OP_ADD;
                endcase
            end
            
            // I-Type Instructions (ADDI)
            7'b0010011: begin
                ALUSrc = 1'b1; 
                RegWrite = 1'b1;
                MemWrite = 1'b0;
                ResultSrc = 1'b0;
                ALUControl = OP_ADD;
            end

            // Load word (lw)
            7'b0000011: begin
                ALUSrc = 1'b1; 
                RegWrite = 1'b1;
                MemWrite = 1'b0;
                ResultSrc = 1'b1; 
                ALUControl = OP_ADD;
            end

            // Store Word (sw)
            7'b0100011: begin
                ALUSrc = 1'b1; 
                RegWrite = 1'b0;
                MemWrite = 1'b1;
                ResultSrc = 1'b0; 
                ALUControl = OP_ADD;
            end
            
            default: begin
                ALUSrc = 1'b0;
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 1'b0; 
                ALUControl = OP_ADD;
            end
        endcase
    end
endmodule