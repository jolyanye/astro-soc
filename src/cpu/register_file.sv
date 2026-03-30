module register_file (
    input logic clk,
    input logic we3,  // Write enable
    input logic [4:0] a1,  // SrcA address
    input logic [4:0] a2,  // SrcB address
    input logic [4:0] a3,  // Dest address
    input logic [31:0] wd3,  // Data to write
    output logic [31:0] rd1,  // SrcA
    output logic [31:0] rd2  // SrcB
);
    logic [31:0] rf [31:0];

    assign rd1 = (a1 == 5'd0) ? 32'd0 : rf[a1];
    assign rd2 = (a2 == 5'd0) ? 32'd0 : rf[a2];

    always_ff @(posedge clk) begin
        if (we3 && a3 != 5'd0) begin
            rf[a3] <= wd3;
        end
    end
endmodule