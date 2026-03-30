module systolic_array #(
    parameter ARRAY_SIZE = 8
)(
    input logic clk,
    input logic rst_n,

    // Stationary weights
    input logic signed [7:0] i_weight [ARRAY_SIZE][ARRAY_SIZE],
    
    // Input data from the left
    input logic signed [7:0] i_act_left [ARRAY_SIZE],

    // Input partial sums from the top
    input logic signed [23:0] i_psum_top [ARRAY_SIZE],

    // Output data to the right
    output logic signed [7:0] o_act_right [ARRAY_SIZE],

    // Output partial sums to the bottom
    output logic signed [23:0] o_psum_bot [ARRAY_SIZE]
);
    logic signed [7:0] w_act [ARRAY_SIZE][ARRAY_SIZE+1];
    logic signed [23:0] w_psum [ARRAY_SIZE+1][ARRAY_SIZE];

    genvar i;
    generate
        for (i = 0; i < ARRAY_SIZE; i++) begin : bound_loop
            assign w_act[i][0] = i_act_left[i];
            assign w_psum[0][i] = i_psum_top[i];
            assign o_act_right[i] = w_act[i][ARRAY_SIZE];
            assign o_psum_bot[i]  = w_psum[ARRAY_SIZE][i];
        end
    endgenerate

    genvar row, col;
    generate
        for (row = 0; row < ARRAY_SIZE; row++) begin : row_loop
            for (col = 0; col < ARRAY_SIZE; col++) begin : col_loop
                processing_element PE_inst (
                    .clk(clk),
                    .rst_n(rst_n),
                    .i_weight(i_weight[row][col]),
                    .i_act_left(w_act[row][col]),
                    .i_psum_top(w_psum[row][col]),
                    .o_act_right(w_act[row][col+1]),
                    .o_psum_bot(w_psum[row+1][col])
                );
            end
        end
    endgenerate
endmodule