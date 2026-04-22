module top_soc (
    input logic clk,
    input logic rst_n,
    
    input logic [31:0] instr,
    output logic [31:0] PC,

    output logic tpu_start,
    output logic [31:0] tpu_weight_ptr,
    output logic [31:0] tpu_act_ptr,
    input logic tpu_done
);

    // =========================================================
    // The AXI Interconnect (The physical copper wires)
    // =========================================================
    // Write Address Channel
    wire [31:0] axi_awaddr;
    wire axi_awvalid;
    wire axi_awready;

    // Write Data Channel
    wire [31:0] axi_wdata;
    wire axi_wvalid;
    wire axi_wready;

    // Write Response Channel
    wire [1:0] axi_bresp;
    wire axi_bvalid;
    wire axi_bready;

    // Read Address Channel
    wire [31:0] axi_araddr;
    wire axi_arvalid;
    wire axi_arready;

    // Read Data Channel
    wire [31:0] axi_rdata;
    wire [1:0] axi_rresp;
    wire axi_rvalid;
    wire axi_rready;

    // CPU
    datapath cpu_core (
        .clk(clk),
        .rst_n(rst_n),
        .instr(instr),
        .PC(PC),

        // AXI Master Ports
        .M_AXI_AWADDR(axi_awaddr),
        .M_AXI_AWVALID(axi_awvalid),
        .M_AXI_AWREADY(axi_awready),
        .M_AXI_WDATA(axi_wdata),
        .M_AXI_WVALID(axi_wvalid),
        .M_AXI_WREADY(axi_wready),
        .M_AXI_BRESP(axi_bresp),
        .M_AXI_BVALID(axi_bvalid),
        .M_AXI_BREADY(axi_bready),
        .M_AXI_ARADDR(axi_araddr),
        .M_AXI_ARVALID(axi_arvalid),
        .M_AXI_ARREADY(axi_arready),
        .M_AXI_RDATA(axi_rdata),
        .M_AXI_RRESP(axi_rresp),
        .M_AXI_RVALID(axi_rvalid),
        .M_AXI_RREADY(axi_rready)
    );

    // Astro-TPU Wrapper
    tpu_axi_wrapper tpu_accelerator (
        .S_AXI_ACLK(clk),
        .S_AXI_ARESETN(rst_n),
        
        // AXI Slave Ports
        .S_AXI_AWADDR(axi_awaddr[3:0]),
        .S_AXI_AWVALID(axi_awvalid),
        .S_AXI_AWREADY(axi_awready),
        .S_AXI_WDATA(axi_wdata),
        .S_AXI_WSTRB(4'b1111),
        .S_AXI_WVALID(axi_wvalid),
        .S_AXI_WREADY(axi_wready),
        .S_AXI_BRESP(axi_bresp),
        .S_AXI_BVALID(axi_bvalid),
        .S_AXI_BREADY(axi_bready),
        .S_AXI_ARADDR(axi_araddr[3:0]),
        .S_AXI_ARVALID(axi_arvalid),
        .S_AXI_ARREADY(axi_arready),
        .S_AXI_RDATA(axi_rdata),
        .S_AXI_RRESP(axi_rresp),
        .S_AXI_RVALID(axi_rvalid),
        .S_AXI_RREADY(axi_rready),

        // Connections to tpu
        .tpu_start(tpu_start),
        .tpu_weight_ptr(tpu_weight_ptr),
        .tpu_act_ptr(tpu_act_ptr),
        .tpu_done(tpu_done)
    );
endmodule