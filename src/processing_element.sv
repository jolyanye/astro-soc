module processing_element (
    input logic clk,
    input logic rst_n,
    input logic signed [7:0] i_weight,
    
    // Input data flowing in from left & top neighbors
    input logic signed [7:0] i_act_left,
    input logic signed [23:0] i_psum_top,

    // Output data sent out to right & bottom neighbors
    output logic signed [7:0] o_act_right,
    output logic signed [23:0] o_psum_bot
);
    logic signed [15:0] mult_res;
    logic signed [23:0] next_psum;

    assign mult_res = i_weight * i_act_left;
    assign next_psum = i_psum_top + mult_res;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_act_right <= 8'sd0;
            o_psum_bot <= 24'sd0;
        end else begin
            o_act_right <= i_act_left;
            o_psum_bot <= next_psum;
        end
    end
endmodule

