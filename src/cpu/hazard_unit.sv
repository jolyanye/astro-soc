module hazard_unit (
    input logic [4:0] rs1_D,
    input logic [4:0] rs2_D,
    input logic [4:0] rd_E,
    input logic ResultSrc_E,  // = 1 means load word in MEM stage
    input logic PCSrc_E,
    input logic AXI_Stall,
    output logic StallF,  
    output logic StallD,  
    output logic StallE,
    output logic StallM,
    output logic StallW,
    output logic FlushD,
    output logic FlushE
);
    logic lwStall;

    always_comb begin
        // Load-use hazard
        if (ResultSrc_E == 1'b1 && (rs1_D == rd_E || rs2_D == rd_E)) begin
            lwStall = 1'b1;
        end else begin
            lwStall = 1'b0;
        end
    
        StallF = lwStall | AXI_Stall;
        StallD = lwStall | AXI_Stall;
        StallE = AXI_Stall;
        StallM = AXI_Stall;
        StallW = AXI_Stall;

        // Kill instruction in decode stage if jump instr
        FlushD = PCSrc_E & ~AXI_Stall;
        FlushE = (lwStall | PCSrc_E) & ~AXI_Stall;
    end
endmodule