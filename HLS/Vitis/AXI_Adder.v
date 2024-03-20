/* 
 * AXI  data adder block taking four 128-bit input data and sums them into a 256-bit output data
*/
module axi_adder #(
    parameter SDATA_WIDTH = 128,
    parameter MDATA_WIDTH = 128,     // SDATA_WIDTH + 1
    parameter SSAMPLE_WIDTH = 16,
    parameter MSAMPLE_WIDTH = 16,   // SSAMPLE_WIDTH
    parameter WEIGHT_WIDTH = 8,
    ) 
    (
    input wire clock,
    input wire resetn,
    
    /* all axis prefixed variables should be inferred per UG994 because of the 
     * use of the AXI standard naming convention */

    input reg s00_axi_wstrb,
    input reg s00_axi_wlast,
    input wire s00_axi_wvalid, //zero when reset
    output wire s00_axi_wready, //zero when reset
    input wire [SDATA_WIDTH-1:0] s00_axi_wdata, // 16 8-bit samples
		
    input reg s01_axi_wstrb,
    input reg s01_axi_wlast,
    input wire s01_axi_wvalid, //zero when reset
    output wire s01_axi_wready, //zero when reset
    input wire [SDATA_WIDTH-1:0] s01_axi_wdata, // 16 8-bit samples
		
    input reg s20_axi_wstrb,
    input reg s20_axi_wlast,
    input wire s20_axi_wvalid, //zero when reset
    output wire s20_axi_wready, //zero when reset
    input wire [SDATA_WIDTH-1:0] s20_axi_wdata, // 16 8-bit samples
		
    input reg s21_axi_wstrb,
    input reg s21_axi_wlast,
    input wire s21_axi_wvalid, //zero when reset
    output wire s21_axi_wready, //zero when reset
    input wire [SDATA_WIDTH-1:0] s21_axi_wdata, // 16 8-bit samples
	
    output reg m00_axi_rstrb,
    output reg m00_axi_rlast,
    output wire m00_axi_rvalid, //zero when reset
    input wire m00_axi_rready, //zero when reset
    output wire [MDATA_WIDTH-1:0] m00_axi_rdata, // 16 8-bit samples

    output reg m01_axi_rstrb,
    output reg m01_axi_rlast,
    output wire m01_axi_rvalid, //zero when reset
    input wire m01_axi_rready, //zero when reset
    output wire [MDATA_WIDTH-1:0] m01_axi_rdata, // 16 8-bit samples

    output reg m20_axi_rstrb,
    output reg m20_axi_rlast,
    output wire m20_axi_rvalid, //zero when reset
    input wire m20_axi_rready, //zero when reset
    output wire [MDATA_WIDTH-1:0] m20_axi_rdata, // 16 8-bit samples

    output reg m21_axi_rstrb,
    output reg m21_axi_rlast,
    output wire m21_axi_rvalid, //zero when reset
    input wire m21_axi_rready, //zero when reset
    output wire [MDATA_WIDTH-1:0] m21_axi_rdata, // 16 8-bit samples
    )

    integer samples = SDATA_WIDTH/SSAMPLE_WIDTH;

    integer i;
    reg s_axi_wvalid;
    reg m_axi_rvalid;
    
    always @(posedge CLK)
        begin
            if (resetn == 1'b0) //~resetn
                begin
                    // data out, valid, tread, and tlast should all be 0
                    m00_axis_wdata <= 0;
                    m00_axi_wlast <= 0;
		    m01_axis_wdata <= 0;
                    m01_axi_wlast <= 0;
		    m20_axis_wdata <= 0;
                    m20_axi_wlast <= 0;
		    m21_axis_wdata <= 0;
                    m21_axi_wlast <= 0;

		    // write
		    m00_axi_wvalid <= 0;
		    s00_axi_wready <= 0;
		    s01_axi_wready <= 0;
		    s20_axi_wready <= 0;
		    s21_axi_wready <= 0;

	            // ?
		    m00_axi_bvalid <= 0;
		    s00_axi_bready <= 0;
		    s01_axi_bready <= 0;
		    s20_axi_bready <= 0;
		    s21_axi_bwready <= 0;
                end
            else
                begin
                    // input tready goes high (tready = 1'b1)
			m_axi_rlast <= (s00_axi_wlast + s01_axi_wlast + s20_axi_wlast + s21_axi_wlast);

			// if any of the slave axi data streams have valid data, we'll sum them
			s_axi_wvalid <= s00_axi_wvalid | s01_axi_wvalid | s20_axi_wvalid | s21_axi_wvalid;
			m_axi_wvalid <= s00_axi_wvalid | s01_axi_wvalid | s20_axi_wvalid | s21_axi_wvalid;

			
			if(m00_axi_rready && s_axi_wvalid) begin
				// wvalid is now high (wvalid = 1'b1)
                		m_axi_rvalid <= 1'b1;
				// this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
                        	for(i=0; i<samples; i = i+1) begin
					m00_axi_rdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= s00_axi_wdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
				end
			end   
                    end
                    else begin 
                        // invalid data, so output data is set to static value of 0
                        m_axi_rdata <= 256'd0;

			// output valid(s) should be low
                        m_axi_rvalid = 0;
			m_axi_arvalid = 0;
                    end
                end
    end
endmodule
