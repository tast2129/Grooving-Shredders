/* PL_SYSREF_Capture: PL SYSREF capture circuit where the RF-ADC and RF-DAC are 
    operating at the same AXI4-Stream clock frequency (based on the example circuit 
    on page 196 of pg269 (the RF Data Converter LogiCORE IP Product Guide))*/
module PL_SYSREF_Capture 
    input pl_sysref,
    input pl_clock,
    output sysref_adc);

    assign CLK_EN = 1;
    reg pl_clk_internal, pl_clk_buf, pl_sysref_internal;

    // IBUF: Input Buffer
    //       Virtex UltraScale+
    // Xilinx HDL Language Template, version 2022.1

    IBUF IBUF_sysref (
        .O(pl_sysref_internal), // 1-bit output: Buffer output
        .I(pl_sysref)  // 1-bit input: Buffer input
    );

    IBUF IBUF_clk (
        .O(pl_clk_internal), // 1-bit output: Buffer output
        .I(pl_clk)  // 1-bit input: Buffer input
    );

    // End of IBUF_inst instantiation

    // BUFGCE: Global Clock Buffer with Clock Enable, Artix-7
    // Xilinx HDL Language Template, version 2022.1
    BUFGCE BUFGCE_inst (
        .O(pl_clk_buf),          // 1-bit output: Clock output
        .CE(CLK_EN),         // 1-bit input: Clock enable input for I0
        .I(pl_clk_internal)        // 1-bit input: Primary clock
    );
    // End of BUFGCE_inst instantiation

    // differential flip-flop
    always @(posedge pl_clk_buf)
        begin
            sysref_adc <= pl_sysref_internal;
        end
endmodule
