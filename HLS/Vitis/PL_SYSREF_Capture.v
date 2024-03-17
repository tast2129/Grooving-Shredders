/* PL_SYSREF_Capture: PL SYSREF capture circuit where the RF-ADC and RF-DAC are 
    operating at the same AXI4-Stream clock frequency (based on the example circuit 
    on page 196 of pg269 (the RF Data Converter LogiCORE IP Product Guide))*/

// inputs using Xilinx differential clock attributes
//*(* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 pl_sysref CLK_P" *)*/ input reg pl_sysref_p,
//*(* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 pl_sysref CLK_N" *)*/ input reg pl_sysref_n,
//*(* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 pl_clk CLK_P" *)*/ input wire pl_clk_p,
//*(* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 pl_clk CLK_N" *)*/ input wire pl_clk_n,
`default_nettype none

module PL_SYSREF_Capture (
    input reg pl_sysref_p,
    input reg pl_sysref_n,
    input wire pl_clk_p,
    input wire pl_clk_n,
    output reg sysref_adc);

    wire CLK_EN;
    assign CLK_EN = 1;
    reg pl_clk_in, pl_sysref, pl_clk; 

    // IBUFDS: Differential Input Buffer, Artix-7
    // Xilinx HDL Language Template, version 2022.1
    IBUFDS #(
        .DIFF_TERM("FALSE"),       // Differential Termination
        .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
        .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
    ) IBUFDS_sysref (
        .O(pl_sysref),             // Buffer output
        .I(pl_sysref_p),           // Diff_p buffer input (connect directly to top-level port)
        .IB(pl_sysref_n)           // Diff_n buffer input (connect directly to top-level port)
    );

    IBUFDS #(
        .DIFF_TERM("FALSE"),       // Differential Termination
        .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
        .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
    ) IBUFDS_clk (
        .O(pl_clk_in),             // Buffer output
        .I(pl_clk_p),              // Diff_p buffer input (connect directly to top-level port)
        .IB(pl_clk_n)              // Diff_n buffer input (connect directly to top-level port)
    );
    // End of IBUFDS_sysref and IBUFDS_clk instantiation


    // BUFGCE: Global Clock Buffer with Clock Enable, Artix-7
    // Xilinx HDL Language Template, version 2022.1
    BUFGCE BUFGCE_inst (
        .O(pl_clk),          // 1-bit output: Clock output
        .CE(CLK_EN),         // 1-bit input: Clock enable input for I0
        .I(pl_clk_in)        // 1-bit input: Primary clock
    );
    // End of BUFGCE_inst instantiation
   

    // differential flip-flop
    always @(posedge pl_clk)
        begin
            sysref_adc <= pl_sysref;
        end
endmodule

`default_nettype wire
