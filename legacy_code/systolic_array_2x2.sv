module systolic_array_2x2 (
    input logic clk,
    input logic rst_n,

    // Stationary weights
    input logic signed [7:0] w_00, w_01, w_10, w_11,
    
    // Input data from the left
    input logic signed [7:0] i_act_row0,
    input logic signed [7:0] i_act_row1,

    // Input partial sums from the top
    input logic signed [23:0] i_psum_col0,
    input logic signed [23:0] i_psum_col1,

    // Output data to the right
    output logic signed [7:0] o_act_row0,
    output logic signed [7:0] o_act_row1,

    // Output partial sums to the bottom
    output logic signed [23:0] o_psum_col0,
    output logic signed [23:0] o_psum_col1
);
    logic signed [23:0] w_psum_col0;
    logic signed [23:0] w_psum_col1;
    logic signed [7:0] w_act_row0;
    logic signed [7:0] w_act_row1;

    processing_element PE_00 (
        .clk(clk),
        .rst_n(rst_n),
        .i_weight(w_00),
        .i_act_left(i_act_row0),
        .i_psum_top(i_psum_col0),
        .o_act_right(w_act_row0),
        .o_psum_bot(w_psum_col0)
    );

    processing_element PE_01 (
        .clk(clk),
        .rst_n(rst_n),
        .i_weight(w_01),
        .i_act_left(w_act_row0),
        .i_psum_top(i_psum_col1),
        .o_act_right(o_act_row0),
        .o_psum_bot(w_psum_col1)
    );

endmodule