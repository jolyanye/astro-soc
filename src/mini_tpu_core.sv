module mini_tpu_core #(
    parameter ARRAY_SIZE = 8
) (
    input logic clk,
    input logic rst_n,
    input logic signed [7:0] i_weight [ARRAY_SIZE][ARRAY_SIZE],
    input logic signed [7:0] i_flat_act [ARRAY_SIZE],
    input logic signed [23:0] i_psum_top [ARRAY_SIZE],
    input logic signed [23:0] o_psum_bot [ARRAY_SIZE]
);
    logic signed [7:0] w_skewed_act [ARRAY_SIZE];
    logic signed [7:0] w_act_garbage [ARRAY_SIZE];

    skew_buffer #(
        .ARRAY_SIZE(ARRAY_SIZE)
    ) u_skew_buffer (
        .clk(clk),
        .rst_n(rst_n),
        .i_flat_act(i_flat_act),
        .o_skewed_act(w_skewed_act)
    );

    systolic_array #(
        .ARRAY_SIZE(ARRAY_SIZE)
    ) u_systolic_array (
        .clk (clk),
        .rst_n(rst_n),
        .i_weight(i_weight),
        .i_act_left(w_skewed_act), 
        .i_psum_top(i_psum_top),
        .o_act_right(w_act_garbage), 
        .o_psum_bot(o_psum_bot)
    );

endmodule