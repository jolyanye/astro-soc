module hazard_unit (
    input logic [4:0] rs1_D,
    input logic [4:0] rs2_D,
    input logic [4:0] rd_E,
    input logic ResultSrc_E,  // = 1 means load word in MEM stage
    input logic PCSrc_E,
    output logic StallF,  // freezes PC
    output logic StallD,  // freezes IF/ID reg
    output logic FlushD,
    output logic FlushE  // disable all control signals
);
    logic lwStall;

    always_comb begin
        // Load-use hazard
        if (ResultSrc_E == 1'b1 && (rs1_D == rd_E || rs2_D == rd_E)) begin
            lwStall = 1'b1;
        end else begin
            lwStall = 1'b0;
        end
    
        StallF = lwStall;
        StallD = lwStall;

        // Kill instruction in decode stage if jump instr
        FlushD = PCSrc_E;
        FlushE = lwStall | FlushE;
    end
endmodule