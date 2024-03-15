/* 
 * AXI stream adder block taking four 128-bit input data and sums them into a 256-bit output data
*/
module axis_quad_adder
  #(
    parameter SDATA_WIDTH = 128,
    parameter MDATA_WIDTH = 256     // MSAMPLE_WIDTH * SAMPLES
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
	input reg s00_axi_arid,
	input reg s00_axi_araddr,
	input reg s00_axi_arlen,
	input reg s00_axi_arsize,
	input reg s00_axi_arburst,
	input reg s00_axi_arlock,
	input reg s00_axi_cache,
	input reg s00_axi_arprot,
	input reg s00_axi_arregion,
	input reg s00_axi_arqos,
	input wire s00_axi_arvalid, //zero when reset
	input wire s00_axi_arready, //zero when reset
	input reg s00_axi_rid,
	input reg s00_axi_rdata,
	input reg s00_axi_rresp,
	input reg s00_axi_rlast,
	input wire s00_axi_rvalid, //zero when reset
	input wire s00_axi_rready, //zero when reset
    input wire [SDATA_WIDTH-1:0] s00_axi_tdata, // 16 8-bit samples
    input reg s00_axi_tlast, //possibly don't need
		
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
	input reg s01_axi_arid,
	input reg s01_axi_araddr,
	input reg s01_axi_arlen,
	input reg s01_axi_arsize,
	input reg s01_axi_arburst,
	input reg s01_axi_arlock,
	input reg s01_axi_cache,
	input reg s01_axi_arprot,
	input reg s01_axi_arregion,
	input reg s01_axi_arqos,
	input wire s01_axi_arvalid, //zero when reset
	input wire s01_axi_arready, //zero when reset
	input reg s01_axi_rid,
	input reg s01_axi_rdata,
	input reg s01_axi_rresp,
	input reg s01_axi_rlast,
	input wire s01_axi_rvalid, //zero when reset
	input wire s01_axi_rready, //zero when reset
    input wire [SDATA_WIDTH-1:0] s01_axi_tdata, // 16 8-bit samples
    input reg s01_axi_tlast, //possibly don't need
		
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
	input reg s20_axi_arid,
	input reg s20_axi_araddr,
	input reg s20_axi_arlen,
	input reg s20_axi_arsize,
	input reg s20_axi_arburst,
	input reg s20_axi_arlock,
	input reg s20_axi_cache,
	input reg s20_axi_arprot,
	input reg s20_axi_arregion,
	input reg s20_axi_arqos,
	input wire s20_axi_arvalid, //zero when reset
	input wire s20_axi_arready, //zero when reset
	input reg s20_axi_rid,
	input reg s20_axi_rdata,
	input reg s20_axi_rresp,
	input reg s20_axi_rlast,
	input wire s20_axi_rvalid, //zero when reset
	input wire s20_axi_rready, //zero when reset
    input wire [SDATA_WIDTH-1:0] s20_axi_tdata, // 16 8-bit samples
    input reg s20_axi_tlast, //possibly don't need
		
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
	input reg s21_axi_arid,
	input reg s21_axi_araddr,
	input reg s21_axi_arlen,
	input reg s21_axi_arsize,
	input reg s21_axi_arburst,
	input reg s21_axi_arlock,
	input reg s21_axi_cache,
	input reg s21_axi_arprot,
	input reg s21_axi_arregion,
	input reg s21_axi_arqos,
	input wire s21_axi_arvalid, //zero when reset
	input wire s21_axi_arready, //zero when reset
	input reg s21_axi_rid,
	input reg s21_axi_rdata,
	input reg s21_axi_rresp,
	input reg s21_axi_rlast,
	input wire s21_axi_rvalid, //zero when reset
	input wire s21_axi_rready, //zero when reset
    input wire [SDATA_WIDTH-1:0] s21_axi_tdata, // 16 8-bit samples
    input reg s21_axi_tlast, //possibly don't need

    output reg [MDATA_WIDTH-1:0] m_axis_s2mm_tdata,
    output reg [SDATA_WIDTH/SSAMPLE_WIDTH-1:0] m_axis_s2mm_tkeep,
    output reg m_axi_s2mm_tlast,
    input wire m_axi_s2mm_tready,
    output reg m_axi_s2mm_tvalid);

    integer samples = SDATA_WIDTH/SSAMPLE_WIDTH;

    integer i;
    
    always @(posedge CLK)
        begin
            if (resetn == 1'b0) //~resetn
                begin
                    // data out, valid, tread, and tlast should all be 0
                    m_axis_s2mm_tdata = 0;
                    m_axis_s2mm_tvalid = 0;
                    s_axis_tready = 0;
                    m_axis_s2mm_tlast = 0;
                end
            else
                begin
                    // input tready goes high (tready = 1'b1)
                    m_axis_s2mm_tlast <= s_axis_tlast;

                    if(m_axis_s2mm_tready && s_axis_tvalid) begin
                        // tkeep and tvalid are now high (tkeep = 16'hffff, tvalid = 1'b1)
                        m_axis_s2mm_tkeep <= 16'hffff;
                        m_axis_s2mm_tvalid <= 1'b1;


                        
                    end
                    else begin 
                        // invalid data, so output data is set to static value of 0
                        m_axis_s2mm_tdata <= 256'd0;

                        // output valid and output tkeep should be low
                        m_axis_s2mm_tvalid <= 0;
                        m_axis_s2mm_tkeep <= 0;
                    end
                end
    end
endmodule
