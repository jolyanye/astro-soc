module skew_buffer #(
    parameter ARRAY_SIZE = 8
) (
    input logic clk,
    input logic rst_n,
    input logic signed [7:0] i_flat_act [ARRAY_SIZE],
    output logic signed [7:0] o_skewed_act [ARRAY_SIZE]
);
    logic signed [7:0] delay_regs [ARRAY_SIZE][ARRAY_SIZE];

    assign o_skewed_act[0] = i_flat_act[0];

    genvar row;
    generate
        for (row = 1; row < ARRAY_SIZE; row++) begin : row_delay
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    for (int i = 0; i < row; i++) begin
                        delay_regs[row][i] <= 8'sd0;
                    end
                end else begin
                    delay_regs[row][0] <= i_flat_act[row];
                    for (int j = 1; j < row; j++) begin
                        delay_regs[row][j] <= delay_regs[row][j-1];
                    end
                end
            end

            assign o_skewed_act[row] = delay_regs[row][row-1];
        end
    endgenerate
endmodule