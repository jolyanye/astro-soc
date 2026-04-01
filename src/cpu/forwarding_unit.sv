module forwarding_unit (
    // Data needed by ALU immediately
    input logic [4:0] rs1_E,
    input logic [4:0] rs2_E,

    // What MEM stage is holding
    input logic [4:0] rd_M,
    input logic RegWrite_M,

    // What WB stage is holding
    input logic [4:0] rd_W,
    input logic RegWrite_W,

    // Forwarding unit controls
    output logic [1:0] ForwardA,  // for ALU 1st input
    output logic [1:0] ForwardB  // for ALU 2nd input
);
    always_comb begin
        if (RegWrite_M == 1 && rd_M == rs1_E && rd_M != 0) begin
            ForwardA = 2'b10;  // forward from MEM
        end else if (RegWrite_W == 1 && rd_W == rs1_E && rd_W != 0) begin
            ForwardA = 2'b01;  // forward from WB
        end else begin
            ForwardA = 2'b00; // no hazard
        end

        if (RegWrite_M == 1 && rd_M == rs2_E && rd_M != 0) begin
            ForwardB = 2'b10;
        end else if (RegWrite_W == 1 && rd_W == rs2_E && rd_W != 0) begin
            ForwardB = 2'b01;
        end else begin
            ForwardB = 2'b00;
        end
    end
endmodule