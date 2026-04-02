module tpu_axi_wrapper (
    input logic S_AXI_ACLK,
    input logic S_AXI_ARESETN,
    
    // Write address channel (AW)
    input logic [3:0] S_AXI_AWADDR,
    input logic S_AXI_AWVALID,
    output logic S_AXI_AWREADY,

    // Write data channel (W)
    input logic [31:0] S_AXI_WDATA,
    input logic [3:0] S_AXI_WSTRB,
    input logic S_AXI_WVALID,
    output logic S_AXI_WREADY,

    // Write response channel (B)
    output logic [1:0] S_AXI_BRESP,
    output logic S_AXI_BVALID,
    input logic S_AXI_BREADY,

    // Read address channel (AR)
    input logic [3:0] S_AXI_ARADDR,
    input logic S_AXI_ARVALID,
    output logic S_AXI_ARREADY,

    // Read data channel (R)
    output logic [31:0] S_AXI_RDATA,
    output logic [1:0] S_AXI_RRESP,
    output logic S_AXI_RVALID,
    input logic S_AXI_RREADY,

    // Connections to mini-TPU core
    output logic tpu_start,
    output logic [31:0] tpu_weight_ptr,
    output logic [31:0] tpu_act_ptr,
    input logic tpu_done
);
    logic [31:0] csr_control;  // 0x00
    logic [31:0] csr_weight;  // 0x08
    logic [31:0] csr_act;  // 0x0C

    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_AWREADY <= 1'b0;
            S_AXI_WREADY <= 1'b0;
            S_AXI_BVALID <= 1'b0;
            S_AXI_ARREADY <= 1'b0;
            S_AXI_RVALID <= 1'b0;
            csr_control <= 32'd0;
            csr_weight <= 32'd0;
            csr_act <= 32'd0;
        end else begin
            // CPU holding out address & data
            if (S_AXI_AWVALID && S_AXI_WVALID && ~S_AXI_AWREADY && ~S_AXI_WREADY) begin
                S_AXI_AWREADY <= 1'b1;
                S_AXI_WREADY <= 1'b1;
            end else begin
                S_AXI_AWREADY <= 1'b0;
                S_AXI_WREADY <= 1'b0;
            end

            // Capture CPU address & data and send read receipt back to CPU
            if (S_AXI_AWVALID && S_AXI_WVALID && S_AXI_AWREADY && S_AXI_WREADY) begin
                case (S_AXI_AWADDR)
                    4'h00: csr_control <= S_AXI_WDATA;
                    4'h08: csr_weight <= S_AXI_WDATA;
                    4'h0C: csr_act <= S_AXI_WDATA;
                endcase
                S_AXI_BVALID <= 1'b1;
            end else if (S_AXI_BREADY & S_AXI_BVALID) begin
                S_AXI_BVALID <= 1'b0;
            end

            // CPU provides address it wants TPU to read from
            if (S_AXI_ARVALID & ~S_AXI_ARREADY) begin
                S_AXI_ARREADY <= 1'b1;
            end else begin
                S_AXI_ARREADY <= 1'b0;
            end

            // TPU fetches data from provided address
            if (S_AXI_ARVALID & S_AXI_ARREADY) begin
                S_AXI_RVALID <= 1'b1;
                case (S_AXI_ARADDR)
                    4'h00: S_AXI_RDATA <= csr_control;
                    4'h04: S_AXI_RDATA <= {31'd0, tpu_done};
                    default: S_AXI_RDATA <= 32'd0;
                endcase
            end else if (S_AXI_RREADY && S_AXI_RVALID) begin
                S_AXI_RVALID <= 1'b0;
            end
        end
    end

    assign tpu_start = csr_control[0];
    assign tpu_weight_ptr = csr_weight;
    assign tpu_act_ptr = csr_act;
    assign S_AXI_BRESP = 2'b00;
    assign S_AXI_RRESP = 2'b00;
endmodule