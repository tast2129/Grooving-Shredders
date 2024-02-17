   // dff: Differential Flip-Flop module
   module dff
        (
        input wire pl_clk, reset,
        input wire pl_sysref,
        output reg q
        );
 
     always @(posedge pl_clk, posedge reset)
        if (reset)
            q <= 1'b0;
        else
            q <= pl_sysref;
   endmodule   


  /* PL_SYSREF_Capture: PL SYSREF capture circuit where the RF-ADC and RF-DAC are 
  operating at the same AXI4-Stream clock frequency (based on the example circuit 
  on page 196 of pg269 (the RF Data Converter LogiCORE IP Product Guide))*/
   module PL_SYSREF_Capture 
        (
        input PL_SYSREF_P, PL_SYSREF_N,
        input PL_CLOCK_P, PL_CLOCK_N,
        input RESET, CLK_EN,
        output sysref_adc);

     reg pl_clk_in, pl_sysref, pl_clk; 

     // IBUFDS: Differential Input Buffer, Artix-7
     // Xilinx HDL Language Template, version 2022.1
     IBUFDS #(
        .DIFF_TERM("FALSE"),       // Differential Termination
        .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
        .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
     ) IBUFDS_sysref (
        .O(pl_sysref),              // Buffer output
        .I(PL_SYSREF_P),            // Diff_p buffer input (connect directly to top-level port)
        .IB(PL_SYSREF_N)            // Diff_n buffer input (connect directly to top-level port)
     );

     IBUFDS #(
        .DIFF_TERM("FALSE"),       // Differential Termination
        .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
        .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
     ) IBUFDS_clk (
        .O(pl_clk),                 // Buffer output
        .I(PL_CLOCK_P),             // Diff_p buffer input (connect directly to top-level port)
        .IB(PL_CLOCK_N)             // Diff_n buffer input (connect directly to top-level port)
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


     // dff: Differential Flip-Flop Instantiation
     dff dff_sysref(.pl_clk(pl_clk), .reset(RESET), .pl_sysref(pl_sysref), .q(sysref_adc));
   endmodule
