module alu (
    input logic [31:0] SrcA,
    input logic [31:0] SrcB,
    input logic [2:0] ALUControl,
    output logic [31:0] ALUResult,
    output logic Zero
);
    localparam [2:0] OP_ADD = 3'b000;
    localparam [2:0] OP_SUB = 3'b001;
    localparam [2:0] OP_AND = 3'b010;
    localparam [2:0] OP_OR = 3'b011;

    always_comb begin
        ALUResult = 32'd0;
        case (ALUControl)
            OP_ADD: ALUResult = SrcA + SrcB;
            OP_SUB: ALUResult = SrcA - SrcB;
            OP_AND: ALUResult = SrcA & SrcB;
            OP_OR: ALUResult = SrcA | SrcB;
            default: ALUResult = 32'd0;
        endcase
    end

    assign Zero = (ALUResult == 32'd0);
endmodule