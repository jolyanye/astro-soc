module npu_core (
    // Global signals
    input logic clk,
    input logic rst_n,

    // CPU control interface
    input logic i_start,
    input logic [7:0] i_length,
    output logic o_layer_done,
    output logic signed [23:0] o_mac_result,

    // SRAM memory interface
    output logic [7:0] o_sram_addr,
    input logic signed [7:0] i_weight_data,
    input logic signed [7:0] i_act_data
);
    // Internal wires
    logic [7:0] w_curr_addr;
    logic w_is_done;
    logic w_mac_valid;
    
    // Control logic
    assign w_mac_valid = i_start && !w_is_done;
    assign o_layer_done = w_is_done;
    assign o_sram_addr = w_curr_addr;

    // Instantiate vector controller
    vector_controller u_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .i_start(i_start),
        .i_length(i_length),
        .o_address_ptr(w_curr_addr),
        .o_done(w_is_done)
    );

    mac_engine u_mac (
        .clk(clk),
        .rst_n(rst_n),
        .i_weight(i_weight_data),
        .i_act(i_act_data),
        .i_valid(w_mac_valid),
        .o_result(o_mac_result)
    );
endmodule