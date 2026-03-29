module vector_controller (
    input logic clk,
    input logic rst_n,
    input logic i_start,
    input logic [7:0] i_length,
    output logic [7:0] o_address_ptr,
    output logic o_done
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_address_ptr <= 8'd0;
            o_done <= 1'b0;
        end else if (i_start && !o_done) begin
            if (o_address_ptr == (i_length - 8'd1)) begin
                o_done <= 1'b1;
            end else begin
                o_address_ptr <= o_address_ptr + 8'd1;
            end
        end
    end
endmodule