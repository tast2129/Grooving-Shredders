/* 
 * AXI data adder block taking four 128-bit input data and outputs them
 * This block is completely unnecessary and serves to confirm we're interfacing
 * correctly before implementing the adder portion of this block
*/
module axi_adder #(
    parameter SDATA_WIDTH = 128,
    parameter MDATA_WIDTH = 128,     // SDATA_WIDTH + 1
    parameter SSAMPLE_WIDTH = 8,
    parameter MSAMPLE_WIDTH = 8,   // SSAMPLE_WIDTH
    parameter WEIGHT_WIDTH = 8
    ) 
    (
    input wire clock,
    input wire resetn,

    // these will be the multiplication factor for all 16 samples in each channel, each should be <1
    input [WEIGHT_WIDTH:0] bWeight00_imag, input [WEIGHT_WIDTH:0] bWeight00_real,
    input [WEIGHT_WIDTH:0] bWeight01_imag, input [WEIGHT_WIDTH:0] bWeight01_real,
    input [WEIGHT_WIDTH:0] bWeight20_imag, input [WEIGHT_WIDTH:0] bWeight20_real,
    input [WEIGHT_WIDTH:0] bWeight21_imag, input [WEIGHT_WIDTH:0] bWeight21_real,
    
    /* all axis prefixed variables should be inferred per UG994 because of the 
     * use of the AXI standard naming convention */

    input s00_axi_wstrb,
    input s00_axi_wlast,
    input s00_axi_wvalid, //zero when reset
    output s00_axi_wready, //zero when reset
    input [SDATA_WIDTH-1:0] s00_axi_wdata, // 16 8-bit samples
		
    input s01_axi_wstrb,
    input s01_axi_wlast,
    input s01_axi_wvalid, //zero when reset
    output s01_axi_wready, //zero when reset
    input [SDATA_WIDTH-1:0] s01_axi_wdata, // 16 8-bit samples
		
    input s20_axi_wstrb,
    input s20_axi_wlast,
    input s20_axi_wvalid, //zero when reset
    output s20_axi_wready, //zero when reset
    input [SDATA_WIDTH-1:0] s20_axi_wdata, // 16 8-bit samples
		
    input s21_axi_wstrb,
    input s21_axi_wlast,
    input s21_axi_wvalid, //zero when reset
    output s21_axi_wready, //zero when reset
    input [SDATA_WIDTH-1:0] s21_axi_wdata, // 16 8-bit samples
	
    output m_axi_rstrb,
    output m_axi_rlast,
    output m_axi_rvalid, //zero when reset
    input m_axi_rready, //zero when reset
    output [MDATA_WIDTH-1:0] m_axi_rdata // 16 8-bit samples
    );

    integer samples = SDATA_WIDTH/SSAMPLE_WIDTH;
    integer i;
    
    always @(posedge CLK) begin
      if (resetn == 1'b0) //~resetn
        begin
          // data out, valid, and wlast should all be 0
          m_axis_wdata <= 0;
          m_axi_wlast <= 0;

		      // write
		      m_axi_rvalid <= 0;
		      s00_axi_wready <= 0;
		      s01_axi_wready <= 0;
		      s20_axi_wready <= 0;
		      s21_axi_wready <= 0;
         end
      else begin
        // input rready goes high (rready = 1'b1)
        m_axi_rlast <= (s00_axi_wlast | s01_axi_wlast | s20_axi_wlast | s21_axi_wlast);

        // if any of the slave axi data streams have valid data, we'll sum them
			  s_axi_wvalid <= s00_axi_wvalid | s01_axi_wvalid | s20_axi_wvalid | s21_axi_wvalid;
        
		    if(m_axi_rready && s_axi_wvalid) begin
			    // input wready goes high (wready = 1'b1)
	   	    m_axi_rlast <= s00_axi_wlast;
			    // wvalid is now high (wvalid = 1'b1)
          m_axi_rvalid <= 1'b1;
          
			    // this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
          for(i=0; i<samples; i = i+1) begin
            m_axi_rdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= 
                (bWeight00_real * s00_axi_wdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH])
              + (bWeight01_real * s01_axi_wdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH])
              + (bWeight20_real * s20_axi_wdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH])
              + (bWeight21_real * s21_axi_wdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]);
			    end
		  end 
		  else begin 
        // invalid data, so output data is set to static value of 0
        m_axi_rdata <= 128'd0;

			  // output valid(s) should be low
        m_axi_rvalid = 0;
      end
    end
endmodule
