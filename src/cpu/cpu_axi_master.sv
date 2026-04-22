module cpu_axi_master (
    input logic clk,
    input logic rst_n,
    
    // CPU Interface
    input logic MemWrite_M,
    input logic MemRead_M,
    input logic [31:0] Address_M,
    input logic [31:0] WriteData_M,
    output logic [31:0] ReadData_M,
    output logic AXI_Stall,
    
    // AXI Write Channels
    output logic [31:0] M_AXI_AWADDR,
    output logic M_AXI_AWVALID,
    input logic M_AXI_AWREADY,
    output logic [31:0] M_AXI_WDATA,
    output logic M_AXI_WVALID,
    input logic M_AXI_WREADY,
    input logic [1:0] M_AXI_BRESP,
    input logic M_AXI_BVALID,
    output logic M_AXI_BREADY,

    // AXI Read Channels
    output logic [31:0] M_AXI_ARADDR,
    output logic M_AXI_ARVALID,
    input logic M_AXI_ARREADY,
    input logic [31:0] M_AXI_RDATA,
    input logic [1:0] M_AXI_RRESP,
    input logic M_AXI_RVALID,
    output logic M_AXI_RREADY
);
    typedef enum logic [2:0] {
        IDLE,
        WRITE_REQ,
        WRITE_ACK,
        READ_REQ,
        READ_ACK
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // CPU Read data capture
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ReadData_M <= 32'd0;
        end else if (M_AXI_RVALID && M_AXI_RREADY) begin
            ReadData_M <= M_AXI_RDATA; // Save the data for the CPU
        end
    end

    always_comb begin
        AXI_Stall = 1'b0;
        next_state = state;
        M_AXI_AWVALID = 1'b0;
        M_AXI_WVALID = 1'b0;
        M_AXI_BREADY = 1'b0;
        M_AXI_ARVALID = 1'b0;
        M_AXI_RREADY  = 1'b0;
        M_AXI_AWADDR  = Address_M;
        M_AXI_WDATA   = WriteData_M;
        M_AXI_ARADDR  = Address_M;

        case (state)
            IDLE: begin
                if (MemWrite_M) begin
                    AXI_Stall = 1'b1;
                    next_state = WRITE_REQ;
                end else if (MemRead_M) begin
                    AXI_Stall = 1'b1;
                    next_state = READ_REQ;
                end
            end
            WRITE_REQ: begin
                AXI_Stall = 1'b1;
                M_AXI_AWVALID = 1'b1;
                M_AXI_WVALID = 1'b1;

                if (M_AXI_AWREADY && M_AXI_WREADY) begin
                    next_state = WRITE_ACK;
                end
            end
            WRITE_ACK: begin
                AXI_Stall = 1'b1;
                M_AXI_BREADY = 1'b1;

                if (M_AXI_BVALID) begin
                    next_state = IDLE;
                end
            end
            READ_REQ: begin
                AXI_Stall = 1'b1;
                M_AXI_ARVALID = 1'b1;
                
                if (M_AXI_ARREADY) begin
                    next_state = READ_ACK;
                end
            end
            READ_ACK: begin
                AXI_Stall = 1'b1;
                M_AXI_RREADY = 1'b1;

                if (M_AXI_RVALID) begin
                    next_state = IDLE;
                end
            end
        endcase
    end
endmodule
            