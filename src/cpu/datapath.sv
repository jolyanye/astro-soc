module datapath (
    input logic clk,
    input logic rst_n,
    input logic [31:0] instr,
    output logic [31:0] PC,

    output logic [31:0] ALUResult_M_out,
    output logic [31:0] WriteData_M_out,
    output logic MemWrite_M_out,
    input  logic [31:0] ReadData_M
);
    // ******************
    // FETCH STAGE
    // ******************
    logic [31:0] PCNext;
    logic Stall_F;
    logic [31:0] PCTarget_E;
    logic PCSrc_E;

    // PC update
    assign PCNext = PCSrc_E ? PCTarget_E : (PC + 32'd4);  // each instr is 4 bytes, each address fits 1 byte -> 4 addresses for each instr

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            PC <= 32'd0;
        end else if (!Stall_F) begin
            PC <= PCNext;
        end
    end

    // ******************
    // IF/ID REGISTER
    // ******************
    logic [31:0] instr_D;
    logic [31:0] PC_D;
    logic Stall_D;
    logic Flush_D;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || Flush_D) begin
            instr_D <= 32'd0;
            PC_D <= 32'd0;
        end else if (!Stall_D) begin
            instr_D <= instr;
            PC_D <= PC;
        end
    end

    // ******************
    // DECODE STAGE
    // ******************
    // Instruction decoding
    logic [6:0] op;
    logic [4:0] rs1, rs2, rd;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign op = instr_D[6:0];
    assign rd = instr_D[11:7];
    assign funct3 = instr_D[14:12];
    assign rs1 = instr_D[19:15];
    assign rs2 = instr_D[24:20];
    assign funct7 = instr_D[31:25];

    // Immediate generation
    logic [31:0] ImmExt_D;
    assign ImmExt_D = {{20{instr_D[31]}}, instr_D[31:20]};

    // Register file
    logic [31:0] rd1_D, rd2_D;
    logic [31:0] Result_W;
    logic RegWrite_W;

    register_file rf_inst (
        .clk(clk),
        .we3(RegWrite_W),
        .a1(rs1),
        .a2(rs2),
        .a3(rd),
        .wd3(Result_W),
        .rd1(rd1_D),
        .rd2(rd2_D)
    );

    // Control unit
    logic RegWrite_D;
    logic ALUSrc_D;
    logic [2:0] ALUControl_D;
    logic MemWrite_D;
    logic ResultSrc_D;
    logic Branch_D;

    control_unit control_inst (
        .op(op),
        .funct3(funct3),
        .funct7_5(instr_D[30]),
        .RegWrite(RegWrite_D),
        .ALUSrc(ALUSrc_D),
        .ALUControl(ALUControl_D),
        .MemWrite(MemWrite_D),
        .ResultSrc(ResultSrc_D),
        .Branch(Branch_D)
    );

    // Hazard unit
    logic Flush_E;

    hazard_unit hu_inst (
        .rs1_D(rs1),
        .rs2_D(rs2),
        .rd_E(rd_target_E),
        .ResultSrc_E(ResultSrc_E),
        .StallF(Stall_F),
        .StallD(Stall_D),
        .FlushD(Flush_D),
        .FlushE(Flush_E)
    );

    // ******************
    // ID/EX REGISTER
    // ******************
    logic [31:0] rd1_E, rd2_E, ImmExt_E;
    logic [4:0] rd_target_E;
    logic RegWrite_E, ALUSrc_E;
    logic [2:0] ALUControl_E;
    logic MemWrite_E, ResultSrc_E;
    logic [4:0] rs1_E, rs2_E;
    logic [4:0] rd_target_M;
    logic RegWrite_M;
    logic [4:0] rd_target_W;
    logic [31:0] PC_E;
    logic Branch_E;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || Flush_E) begin
            rd1_E <= 32'd0;
            rd2_E <= 32'd0;
            ImmExt_E <= 32'd0;
            rd_target_E <= 5'd0;
            RegWrite_E <= 1'b0;
            ALUSrc_E <= 1'b0;
            ALUControl_E <= 3'd0;
            MemWrite_E  <= 1'b0;
            ResultSrc_E <= 1'b0;
            rs1_E <= 5'd0;
            rs2_E <= 5'd0;
            PC_E <= 32'd0;
            Branch_E <= 1'b0;
        end else begin
            rd1_E <= rd1_D;
            rd2_E <= rd2_D;
            ImmExt_E <= ImmExt_D;
            rd_target_E <= rd;
            RegWrite_E <= RegWrite_D;
            ALUSrc_E <= ALUSrc_D;
            ALUControl_E <= ALUControl_D;
            MemWrite_E  <= MemWrite_D;
            ResultSrc_E <= ResultSrc_D;
            rs1_E <= rs1;
            rs2_E <= rs2;
            PC_E <= PC_D;
            Branch_E <= Branch_D;
        end
    end

    // ******************
    // EXECUTE STAGE
    // ******************
    // Forwarding unit
    logic [1:0] ForwardA_E, ForwardB_E;

    forwarding_unit fu_inst (
        .rs1_E(rs1_E),
        .rs2_E(rs2_E),
        .rd_M(rd_target_M),
        .RegWrite_M(RegWrite_M),
        .rd_W(rd_target_W),
        .RegWrite_W(RegWrite_W),
        .ForwardA(ForwardA_E),
        .ForwardB(ForwardB_E)
    );

    // ForwardA MUX
    logic [31:0] SrcA_E;
    always_comb begin
        case (ForwardA_E)
            2'b00: SrcA_E = rd1_E;
            2'b10: SrcA_E = ALUResult_M;
            2'b01: SrcA_E = Result_W;
            default: SrcA_E = rd1_E;
        endcase
    end

    // ForwardB MUX
    logic [31:0] WriteData_E;
    always_comb begin
        case (ForwardB_E)
            2'b00: WriteData_E = rd2_E;
            2'b10: WriteData_E = ALUResult_M;
            2'b01: WriteData_E = Result_W;
            default: WriteData_E = rd2_E;
        endcase
    end

    // ALU Src2 MUX - immediate vs reg
    logic [31:0] SrcB_E;
    assign SrcB_E = ALUSrc_E ? ImmExt_E : WriteData_E;

    // ALU
    logic [31:0] ALUResult_E;
    logic Zero_E;

    alu alu_inst (
        .SrcA(SrcA_E),
        .SrcB(SrcB_E),
        .ALUControl(ALUControl_E),
        .ALUResult(ALUResult_E),
        .Zero(Zero_E)
    );

    assign PCTarget_E = PC_E + ImmExt_E;
    assign PCSrc_E = Branch_E & Zero_E;

    // ******************
    // EX/MEM REGISTER
    // ******************
    logic [31:0] ALUResult_M;
    logic [31:0] WriteData_M;
    logic MemWrite_M, ResultSrc_M;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ALUResult_M <= 32'd0;
            WriteData_M <= 32'd0;
            rd_target_M <= 5'd0;
            RegWrite_M <= 1'b0;
            MemWrite_M  <= 1'b0;
            ResultSrc_M <= 1'b0;
        end else begin
            ALUResult_M <= ALUResult_E;
            WriteData_M <= WriteData_E;
            rd_target_M <= rd_target_E;
            RegWrite_M <= RegWrite_E;
            MemWrite_M  <= MemWrite_E;
            ResultSrc_M <= ResultSrc_E;
        end
    end

    // ******************
    // MEMORY STAGE
    // ******************
    assign ALUResult_M_out = ALUResult_M;
    assign WriteData_M_out = WriteData_M;
    assign MemWrite_M_out  = MemWrite_M;

    // ******************
    // MEM/WB REGISTER
    // ******************
    logic [31:0] ALUResult_W;
    logic [31:0] ReadData_W;
    logic ResultSrc_W;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ALUResult_W <= 32'd0;
            ReadData_W <= 32'd0;
            rd_target_W <= 5'd0;
            RegWrite_W <= 1'b0;
            ResultSrc_W <= 1'b0;
        end else begin
            ALUResult_W <= ALUResult_M;
            ReadData_W <= ReadData_M;
            rd_target_W <= rd_target_M;
            RegWrite_W <= RegWrite_M;
            ResultSrc_W <= ResultSrc_M;
        end
    end

    // ******************
    // WRITEBACK STAGE
    // ******************
    assign Result_W = ResultSrc_W ? ReadData_W : ALUResult_W;

endmodule