/* 
 * AXI  data adder block taking four 128-bit input data and sums them into a 256-bit output data
*/
module axi_adder #(
    parameter SDATA_WIDTH = 256,
    parameter MDATA_WIDTH = 257,     // SDATA_WIDTH + 1
    parameter SSAMPLE_WIDTH = 16,
    parameter MSAMPLE_WIDTH = 16,   // SSAMPLE_WIDTH
    ) 
    (
    input wire clock,
    input wire resetn,
    
    // these will be the multiplication factor for all 16 samples in each channel, each should be <1
    input [WEIGHT_WIDTH-1:0] bWeight00_imag, input [WEIGHT_WIDTH-1:0] bWeight00_real,
    input [WEIGHT_WIDTH-1:0] bWeight01_imag, input [WEIGHT_WIDTH-1:0] bWeight01_real,
    input [WEIGHT_WIDTH-1:0] bWeight20_imag, input [WEIGHT_WIDTH-1:0] bWeight20_real,
    input [WEIGHT_WIDTH-1:0] bWeight21_imag, input [WEIGHT_WIDTH-1:0] bWeight21_real,
    
    /* all axis prefixed variables should be inferred per UG994 because of the 
     * use of the AXI standard naming convention */

    input [0:0]             S00_axi_awid,
    input [48:0]            S00_axi_awaddr,
    input [7:0]             S00_axi_awlen,
    input [2:0]             S00_axi_awsize,
    input [1:0]             S00_axi_awburst,
    input                   S00_axi_awlock,
    input [3:0]             S00_axi_awcache,
    input [2:0]             S00_axi_awprot,
    input                   S00_axi_awregion,
    input [3:0]             S00_axi_awqos,
    input                   S00_axi_awvalid, //zero when reset
    output                  S00_axi_awready, //zero when reset
    input [15:0]            S00_axi_wstrb,
    input                   S00_axi_wlast,
    input                   S00_axi_wvalid, //zero when reset
    output                  S00_axi_wready, //zero when reset
    output [5:0]            S00_axi_bid,
    output [1:0]            S00_axi_bresp,
    output                  S00_axi_bvalid, //zero when reset
    input                   S00_axi_bready, //zero when reset
    input [SDATA_WIDTH-1:0] S00_axi_wdata, // 16 8-bit samples
    input [5:0]             S00_axi_arid,
    input [63:0]            S00_axi_araddr,
    input [7:0]             S00_axi_arlen,
    input [2:0]             S00_axi_arsize,
    input [1:0]             S00_axi_arburst,
    input                   S00_axi_arlock,
    input [3:0]             S00_axi_arcache,
    input [2:0]             S00_axi_arprot,
    input                   S00_axi_arregion,
    input [3:0]             S00_axi_arqos,
    input                   S00_axi_arvalid, //zero when reset
    output                  S00_axi_arready, //zero when reset
    output [1:0]            S00_axi_rresp,
    output                  S00_axi_rlast,
    output                  S00_axi_rvalid, //zero when reset
    input                   S00_axi_rready, //zero when reset
    output[SDATA_WIDTH-1:0] S00_axi_rdata, // 16 8-bit samples
		
    input [5:0]             S01_axi_awid,
    input [48:0]            S01_axi_awaddr,
    input [7:0]             S01_axi_awlen,
    input [2:0]             S01_axi_awsize,
    input [1:0]             S01_axi_awburst,
    input                   S01_axi_awlock,
    input [3:0]             S01_axi_awcache,
    input [2:0]             S01_axi_awprot,
    input                   S01_axi_awregion,
    input [3:0]             S01_axi_awqos,
    input                   S01_axi_awvalid, //zero when reset
    output                  S01_axi_awready, //zero when reset
    input [15:0]            S01_axi_wstrb,
    input                   S01_axi_wlast,
    input                   S01_axi_wvalid, //zero when reset
    output                  S01_axi_wready, //zero when reset
    output [5:0]            S01_axi_bid,
    output [1:0]            S01_axi_bresp,
    output                  S01_axi_bvalid, //zero when reset
    input                   S01_axi_bready, //zero when reset
    input [SDATA_WIDTH-1:0] S01_axi_wdata, // 16 8-bit samples
    input [5:0]             S01_axi_arid,
    input [63:0]            S01_axi_araddr,
    input [7:0]             S01_axi_arlen,
    input [2:0]             S01_axi_arsize,
    input [1:0]             S01_axi_arburst,
    input                   S01_axi_arlock,
    input [3:0]             S01_axi_arcache,
    input [2:0]             S01_axi_arprot,
    input                   S01_axi_arregion,
    input [3:0]             S01_axi_arqos,
    input                   S01_axi_arvalid, //zero when reset
    output                  S01_axi_arready, //zero when reset
    output [1:0]            S01_axi_rresp,
    output                  S01_axi_rlast,
    output                  S01_axi_rvalid, //zero when reset
    input                   S01_axi_rready, //zero when reset
    output[SDATA_WIDTH-1:0] S01_axi_rdata, // 16 8-bit samples
		
    input [5:0]             S21_axi_awid,
    input [48:0]            S21_axi_awaddr,
    input [7:0]             S21_axi_awlen,
    input [2:0]             S21_axi_awsize,
    input [1:0]             S21_axi_awburst,
    input                   S21_axi_awlock,
    input [3:0]             S21_axi_awcache,
    input [2:0]             S21_axi_awprot,
    input                   S21_axi_awregion,
    input [3:0]             S21_axi_awqos,
    input                   S21_axi_awvalid, //zero when reset
    output                  S21_axi_awready, //zero when reset
    input [15:0]            S21_axi_wstrb,
    input                   S21_axi_wlast,
    input                   S21_axi_wvalid, //zero when reset
    output                  S21_axi_wready, //zero when reset
    output [5:0]            S21_axi_bid,
    output [1:0]            S21_axi_bresp,
    output                  S21_axi_bvalid, //zero when reset
    input                   S21_axi_bready, //zero when reset
    input [SDATA_WIDTH-1:0] S21_axi_wdata, // 16 8-bit samples
    input [5:0]             S21_axi_arid,
    input [63:0]            S21_axi_araddr,
    input [7:0]             S21_axi_arlen,
    input [2:0]             S21_axi_arsize,
    input [1:0]             S21_axi_arburst,
    input                   S21_axi_arlock,
    input [3:0]             S21_axi_arcache,
    input [2:0]             S21_axi_arprot,
    input                   S21_axi_arregion,
    input [3:0]             S21_axi_arqos,
    input                   S21_axi_arvalid, //zero when reset
    output                  S21_axi_arready, //zero when reset
    output [1:0]            S21_axi_rresp,
    output                  S21_axi_rlast,
    output                  S21_axi_rvalid, //zero when reset
    input                   S21_axi_rready, //zero when reset
    output[SDATA_WIDTH-1:0] S21_axi_rdata, // 16 8-bit samples
		
    input [5:0]             S20_axi_awid,
    input [48:0]            S20_axi_awaddr,
    input [7:0]             S20_axi_awlen,
    input [2:0]             S20_axi_awsize,
    input [1:0]             S20_axi_awburst,
    input                   S20_axi_awlock,
    input [3:0]             S20_axi_awcache,
    input [2:0]             S20_axi_awprot,
    input                   S20_axi_awregion,
    input [3:0]             S20_axi_awqos,
    input                   S20_axi_awvalid, //zero when reset
    output                  S20_axi_awready, //zero when reset
    input [15:0]            S20_axi_wstrb,
    input                   S20_axi_wlast,
    input                   S20_axi_wvalid, //zero when reset
    output                  S20_axi_wready, //zero when reset
    output [5:0]            S20_axi_bid,
    output [1:0]            S20_axi_bresp,
    output                  S20_axi_bvalid, //zero when reset
    input                   S20_axi_bready, //zero when reset
    input [SDATA_WIDTH-1:0] S20_axi_wdata, // 16 8-bit samples
    input [5:0]             S20_axi_arid,
    input [63:0]            S20_axi_araddr,
    input [7:0]             S20_axi_arlen,
    input [2:0]             S20_axi_arsize,
    input [1:0]             S20_axi_arburst,
    input                   S20_axi_arlock,
    input [3:0]             S20_axi_arcache,
    input [2:0]             S20_axi_arprot,
    input                   S20_axi_arregion,
    input [3:0]             S20_axi_arqos,
    input                   S20_axi_arvalid, //zero when reset
    output                  S20_axi_arready, //zero when reset
    output [1:0]            S20_axi_rresp,
    output                  S20_axi_rlast,
    output                  S20_axi_rvalid, //zero when reset
    input                   S20_axi_rready, //zero when reset
    output[SDATA_WIDTH-1:0] S20_axi_rdata, // 16 8-bit samples
	
    output [5:0]            M00_axi_awid,
    output [48:0]           M00_axi_awaddr,
    output [7:0]            M00_axi_awlen,
    output [2:0]            M00_axi_awsize,
    output [1:0]            M00_axi_awburst,
    output                  M00_axi_awlock,
    output [3:0]            M00_axi_awcache,
    output [2:0]            M00_axi_awprot,
    output                  M00_axi_awregion,
    output [3:0]            M00_axi_awqos,
    output                  M00_axi_awvalid, //zero when reset
    input                   M00_axi_awready, //zero when reset
    output [15:0]           M00_axi_wstrb,
    output                  M00_axi_wlast,
    output                  M00_axi_wvalid, //zero when reset
    input                   M00_axi_wready, //zero when reset
    output[MDATA_WIDTH-1:0] M00_axi_wdata, // 16 8-bit samples
    output [5:0]            M00_axi_arid,
    output [63:0]           M00_axi_araddr,
    output [7:0]            M00_axi_arlen,
    output [2:0]            M00_axi_arsize,
    output [1:0]            M00_axi_arburst,
    output                  M00_axi_arlock,
    output [3:0]            M00_axi_arcache,
    output [2:0]            M00_axi_arprot,
    output                  M00_axi_arregion,
    output [3:0]            M00_axi_arqos,
    output                  M00_axi_arvalid, //zero when reset
    input                   M00_axi_arready, //zero when reset
    input  [1:0]            M00_axi_rresp,
    input                   M00_axi_rlast,
    input                   M00_axi_rvalid, //zero when reset
    output                  M00_axi_rready, //zero when reset
    input  [5:0]            M00_axi_bid,
    input  [1:0]            M00_axi_bresp,
    input                   M00_axi_bvalid, //zero when reset
    output                  M00_axi_bready, //zero when reset
    input [MDATA_WIDTH-1:0] M00_axi_rdata, // 16 8-bit samples

    output [5:0]            M01_axi_awid,
    output [48:0]           M01_axi_awaddr,
    output [7:0]            M01_axi_awlen,
    output [2:0]            M01_axi_awsize,
    output [1:0]            M01_axi_awburst,
    output                  M01_axi_awlock,
    output [3:0]            M01_axi_awcache,
    output [2:0]            M01_axi_awprot,
    output                  M01_axi_awregion,
    output [3:0]            M01_axi_awqos,
    output                  M01_axi_awvalid, //zero when reset
    input                   M01_axi_awready, //zero when reset
    output [15:0]           M01_axi_wstrb,
    output                  M01_axi_wlast,
    output                  M01_axi_wvalid, //zero when reset
    input                   M01_axi_wready, //zero when reset
    output[MDATA_WIDTH-1:0] M01_axi_wdata, // 16 8-bit samples
    output [5:0]            M01_axi_arid,
    output [63:0]           M01_axi_araddr,
    output [7:0]            M01_axi_arlen,
    output [2:0]            M01_axi_arsize,
    output [1:0]            M01_axi_arburst,
    output                  M01_axi_arlock,
    output [3:0]            M01_axi_arcache,
    output [2:0]            M01_axi_arprot,
    output                  M01_axi_arregion,
    output [3:0]            M01_axi_arqos,
    output                  M01_axi_arvalid, //zero when reset
    input                   M01_axi_arready, //zero when reset
    input  [1:0]            M01_axi_rresp,
    input                   M01_axi_rlast,
    input                   M01_axi_rvalid, //zero when reset
    output                  M01_axi_rready, //zero when reset
    input  [5:0]            M01_axi_bid,
    input  [1:0]            M01_axi_bresp,
    input                   M01_axi_bvalid, //zero when reset
    output                  M01_axi_bready, //zero when reset
    input [MDATA_WIDTH-1:0] M01_axi_rdata, // 16 8-bit samples

    output [5:0]            M21_axi_awid,
    output [48:0]           M21_axi_awaddr,
    output [7:0]            M21_axi_awlen,
    output [2:0]            M21_axi_awsize,
    output [1:0]            M21_axi_awburst,
    output                  M21_axi_awlock,
    output [3:0]            M21_axi_awcache,
    output [2:0]            M21_axi_awprot,
    output                  M21_axi_awregion,
    output [3:0]            M21_axi_awqos,
    output                  M21_axi_awvalid, //zero when reset
    input                   M21_axi_awready, //zero when reset
    output [15:0]           M21_axi_wstrb,
    output                  M21_axi_wlast,
    output                  M21_axi_wvalid, //zero when reset
    input                   M21_axi_wready, //zero when reset
    output[MDATA_WIDTH-1:0] M21_axi_wdata, // 16 8-bit samples
    output [5:0]            M21_axi_arid,
    output [63:0]           M21_axi_araddr,
    output [7:0]            M21_axi_arlen,
    output [2:0]            M21_axi_arsize,
    output [1:0]            M21_axi_arburst,
    output                  M21_axi_arlock,
    output [3:0]            M21_axi_arcache,
    output [2:0]            M21_axi_arprot,
    output                  M21_axi_arregion,
    output [3:0]            M21_axi_arqos,
    output                  M21_axi_arvalid, //zero when reset
    input                   M21_axi_arready, //zero when reset
    input  [1:0]            M21_axi_rresp,
    input                   M21_axi_rlast,
    input                   M21_axi_rvalid, //zero when reset
    output                  M21_axi_rready, //zero when reset
    input  [5:0]            M21_axi_bid,
    input  [1:0]            M21_axi_bresp,
    input                   M21_axi_bvalid, //zero when reset
    output                  M21_axi_bready, //zero when reset
    input [MDATA_WIDTH-1:0] M21_axi_rdata, // 16 8-bit samples
    
    output [5:0]            M20_axi_awid,
    output [48:0]           M20_axi_awaddr,
    output [7:0]            M20_axi_awlen,
    output [2:0]            M20_axi_awsize,
    output [1:0]            M20_axi_awburst,
    output                  M20_axi_awlock,
    output [3:0]            M20_axi_awcache,
    output [2:0]            M20_axi_awprot,
    output                  M20_axi_awregion,
    output [3:0]            M20_axi_awqos,
    output                  M20_axi_awvalid, //zero when reset
    input                   M20_axi_awready, //zero when reset
    output [15:0]           M20_axi_wstrb,
    output                  M20_axi_wlast,
    output                  M20_axi_wvalid, //zero when reset
    input                   M20_axi_wready, //zero when reset
    output[MDATA_WIDTH-1:0] M20_axi_wdata, // 16 8-bit samples
    output [5:0]            M20_axi_arid,
    output [63:0]           M20_axi_araddr,
    output [7:0]            M20_axi_arlen,
    output [2:0]            M20_axi_arsize,
    output [1:0]            M20_axi_arburst,
    output                  M20_axi_arlock,
    output [3:0]            M20_axi_arcache,
    output [2:0]            M20_axi_arprot,
    output                  M20_axi_arregion,
    output [3:0]            M20_axi_arqos,
    output                  M20_axi_arvalid, //zero when reset
    input                   M20_axi_arready, //zero when reset
    input  [1:0]            M20_axi_rresp,
    input                   M20_axi_rlast,
    input                   M20_axi_rvalid, //zero when reset
    output                  M20_axi_rready, //zero when reset
    input  [5:0]            M20_axi_bid,
    input  [1:0]            M20_axi_bresp,
    input                   M20_axi_bvalid, //zero when reset
    output                  M20_axi_bready, //zero when reset
    input [MDATA_WIDTH-1:0] M20_axi_rdata // 16 8-bit samples
    )

    integer samples = SDATA_WIDTH/SSAMPLE_WIDTH;

    integer i;
    reg s_axi_wvalid;
    
    always @(posedge CLK)
        begin
            if (resetn == 1'b0) //~resetn
                begin
                    // data out, valid, tread, and tlast should all be 0
                    m_axis_wdata <= 0;
                    m_axi_wlast <= 0;

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
			m_axi_rlast <= (s00_axi_wlast + s01_axi_wlast + s20_axi_wlast + s21_axi_wlast);

			// if any of the slave axi data streams have valid data, we'll sum them
			s_axi_wvalid <= s00_axi_wvalid | s01_axi_wvalid | s20_axi_wvalid | s21_axi_wvalid;
			//m_axi_rready <= m00_axi_rready | m01_axi_rready | m20_axi_rready | m21_axi_rready;

			
			if(m_axi_rready && s_axi_wvalid) begin
				// wvalid is now high (wvalid = 1'b1)
                		m_axi_rvalid <= 1'b1;
				// this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
                        	for(i=0; i<samples; i = i+1) begin
					m_axi_rdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= s00_axi_wdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]
					+ s01_axi_wdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]
					+ s20_axi_wdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]
					+ s21_axi_wdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
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
