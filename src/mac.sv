module mac_engine (
    input logic clk,
    input logic rst_n,
    input logic signed [7:0] i_weight,
    input logic signed [7:0] i_act,
    input logic i_valid,
    output logic signed [23:0] o_result
);
    // Multiplier
    logic signed [15:0] mult_res;
    assign mult_res = i_weight * i_act;

    // Accumulator
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_result <= 24'sd0;
        end else if (i_valid) begin
            // Implement zero-skipping
            if (i_act != 8'sd0) begin
                o_result <= o_result + mult_res;
            end
        end
    end
endmodule