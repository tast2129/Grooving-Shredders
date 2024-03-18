/* 
 * AXI  data adder block taking four 128-bit input data and sums them into a 256-bit output data
*/
module axi_quad_adder
  #(
    parameter SDATA_WIDTH = 256,
    parameter MDATA_WIDTH = 257,     // SDATA_WIDTH + 1
    parameter SSAMPLE_WIDTH = 16,
    parameter MSAMPLE_WIDTH = 16,   // SSAMPLE_WIDTH
   ) 
    (
    	input wire CLK,
    	input wire resetn,
    
    /* all axis prefixed variables should be inferred per UG994 because of the 
     * use of the AXI standard naming convention */

    	input reg s00_axi_awid,
    	input reg s00_axi_awaddr,
    	input reg s00_axi_awlen,
    	input reg s00_axi_awsize,
    	input reg s00_axi_awburst,
   	input reg s00_axi_awlock,
    	input reg s00_axi_awcache,
    	input reg s00_axi_awprot,
    	input reg s00_axi_awregion,
    	input reg s00_axi_awqos,
    	input wire s00_axi_awvalid, //zero when reset
    	input wire s00_axi_awready, //zero when reset
	input reg s00_axi_wdata,
	input reg s00_axi_wstrb,
	input reg s00_axi_wlast,
	input wire s00_axi_wvalid, //zero when reset
	input wire s00_axi_wready, //zero when reset
	input reg s00_axi_bid,
	input reg s00_axi_bresp,
	input wire s00_axi_bvalid, //zero when reset
	input wire s00_axi_bready, //zero when reset
	input wire [SDATA_WIDTH-1:0] s00_axi_wdata, // 16 8-bit samples
    	input reg s00_axi_wlast, //possibly don't need
		
	input reg s01_axi_awid,
    	input reg s01_axi_awaddr,
    	input reg s01_axi_awlen,
    	input reg s01_axi_awsize,
    	input reg s01_axi_awburst,
    	input reg s01_axi_awlock,
    	input reg s01_axi_awcache,
    	input reg s01_axi_awprot,
    	input reg s01_axi_awregion,
    	input reg s01_axi_awqos,
    	input wire s01_axi_awvalid, //zero when reset
	input wire s01_axi_awready, //zero when reset
	input reg s01_axi_wdata,
	input reg s01_axi_wstrb,
	input reg s01_axi_wlast,
	input wire s01_axi_wvalid, //zero when reset
	input wire s01_axi_wready, //zero when reset
	input reg s01_axi_bid,
	input reg s01_axi_bresp,
	input wire s01_axi_bvalid, //zero when reset
	input wire s01_axi_bready, //zero when reset
	input wire [SDATA_WIDTH-1:0] s01_axi_wdata, // 16 8-bit samples
    	input reg s01_axi_wlast, //possibly don't need
		
	input reg s20_axi_awid,
    	input reg s20_axi_awaddr,
    	input reg s20_axi_awlen,
    	input reg s20_axi_awsize,
    	input reg s20_axi_awburst,
    	input reg s20_axi_awlock,
    	input reg s20_axi_awcache,
    	input reg s20_axi_awprot,
    	input reg s20_axi_awregion,
    	input reg s20_axi_awqos,
    	input wire s20_axi_awvalid, //zero when reset
	input wire s20_axi_awready, //zero when reset
	input reg s20_axi_wdata,
	input reg s20_axi_wstrb,
	input reg s20_axi_wlast,
	input wire s20_axi_wvalid, //zero when reset
	input wire s20_axi_wready, //zero when reset
	input reg s20_axi_bid,
	input reg s20_axi_bresp,
	input wire s20_axi_bvalid, //zero when reset
	input wire s20_axi_bready, //zero when reset
	input wire [SDATA_WIDTH-1:0] s20_axi_wdata, // 16 8-bit samples
    	input reg s20_axi_wlast,
		
	input reg s21_axi_awid,
    	input reg s21_axi_awaddr,
    	input reg s21_axi_awlen,
    	input reg s21_axi_awsize,
    	input reg s21_axi_awburst,
    	input reg s21_axi_awlock,
    	input reg s21_axi_awcache,
    	input reg s21_axi_awprot,
    	input reg s21_axi_awregion,
    	input reg s21_axi_awqos,
    	input wire s21_axi_awvalid, //zero when reset
	input wire s21_axi_awready, //zero when reset
	input reg s21_axi_wdata,
	input reg s21_axi_wstrb,
	input reg s21_axi_wlast,
	input wire s21_axi_wvalid, //zero when reset
	input wire s21_axi_wready, //zero when reset
	input reg s21_axi_bid,
	input reg s21_axi_bresp,
	input wire s21_axi_bvalid, //zero when reset
	input wire s21_axi_bready, //zero when reset
	input wire [SDATA_WIDTH-1:0] s21_axi_wdata, // 16 8-bit samples
    	input reg s21_axi_wlast, 
	
	output reg m_axi_awid,
    	output reg m_axi_awaddr,
    	output reg m_axi_awlen,
    	output reg m_axi_awsize,
    	output reg m_axi_awburst,
    	output reg m_axi_awlock,
    	output reg m_axi_awcache,
    	output reg m_axi_awprot,
    	output reg m_axi_awregion,
    	output reg m_axi_awqos,
    	output wire m_axi_awvalid, //zero when reset
	output wire m_axi_awready, //zero when reset
	output reg m_axi_wdata,
	output reg m_axi_wstrb,
	output reg m_axi_wlast,
	output wire m_axi_wvalid, //zero when reset
	output wire m_axi_wready, //zero when reset
	output reg m_axi_bid,
	output reg m_axi_bresp,
	output wire m_axi_bvalid, //zero when reset
	output wire m_axi_bready, //zero when reset
	output wire [MDATA_WIDTH-1:0] m_axi_wdata, // 16 8-bit samples
    	output reg m_axi_wlast //possibly don't need
	)

    integer samples = SDATA_WIDTH/SSAMPLE_WIDTH;

    integer i;
    reg s_axi_wvalid;
    
    always @(posedge CLK)
        begin
            if (resetn == 1'b0) //~resetn
                begin
                    // data out, valid, tread, and tlast should all be 0
                    m_axis_tdata <= 0;
                    m_axi_tlast <= 0;

		    // asynchronous write
		    m_axi_awvalid <= 0;
		    s00_axi_awready <= 0;
		    s01_axi_awready <= 0;
		    s20_axi_awready <= 0;
		    s21_axi_awready <= 0;

		    // write
		    m_axi_wvalid <= 0;
		    s00_axi_wready <= 0;
		    s01_axi_wready <= 0;
		    s20_axi_wready <= 0;
		    s21_axi_wready <= 0;

	            // ?
		    m_axi_bvalid <= 0;
		    s00_axi_bready <= 0;
		    s01_axi_bready <= 0;
		    s20_axi_bready <= 0;
		    s21_axi_bwready <= 0;
                end
            else
                begin
                    // input tready goes high (tready = 1'b1)
			m_axi_wlast <= (s00_axi_wlast + s01_axi_wlast + s20_axi_wlast + s21_axi_wlast);

			// if any of the slave axi data streams have valid data, we'll sum them
			s_axi_wvalid <= s00_axi_wvalid | s01_axi_wvalid | s20_axi_wvalid | s21_axi_wvalid;
			
			if(m_axi_wready && s_axi_wvalid) begin
				// wvalid is now high (wvalid = 1'b1)
                		m_axi_wvalid <= 1'b1;
				m_axi_wdata <= s00_axi_wdata + s01_axi_wdata + s20_axi_wdata + s21_axi_wdata;
			end


                        
                    end
                    else begin 
                        // invalid data, so output data is set to static value of 0
                        m_axi_tdata <= 256'd0;

			// output valid(s) should be low
                        m_axi_wvalid = 0;
			m_axi_awvalid = 0;
                    end
                end
    end
endmodule
