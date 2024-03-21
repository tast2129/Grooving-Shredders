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
    input [WEIGHT_WIDTH-1:0] bWeight00_imag, input [WEIGHT_WIDTH-1:0] bWeight00_real,
    input [WEIGHT_WIDTH-1:0] bWeight01_imag, input [WEIGHT_WIDTH-1:0] bWeight01_real,
    input [WEIGHT_WIDTH-1:0] bWeight20_imag, input [WEIGHT_WIDTH-1:0] bWeight20_real,
    input [WEIGHT_WIDTH-1:0] bWeight21_imag, input [WEIGHT_WIDTH-1:0] bWeight21_real,
    
    /* all axis prefixed variables should be inferred per UG994 because of the 
     * use of the AXI standard naming convention */

    input reg s00_axi_awid,
    input reg s00_axi_awaddr,
    //input reg s00_axi_awlen,
    input reg s00_axi_awsize,
    input reg s00_axi_awburst,
    input reg s00_axi_awlock,
    input reg s00_axi_awcache,
    input reg s00_axi_awprot,
    input reg s00_axi_awregion,
    input reg s00_axi_awqos,
    input wire s00_axi_awvalid, //zero when reset
    output wire s00_axi_awready, //zero when reset
    input reg s00_axi_wstrb,
    input reg s00_axi_wlast,
    input wire s00_axi_wvalid, //zero when reset
    output wire s00_axi_wready, //zero when reset
    input reg s00_axi_bid,
    input reg s00_axi_bresp,
    input wire s00_axi_bvalid, //zero when reset
    output wire s00_axi_bready, //zero when reset
    input wire [SDATA_WIDTH-1:0] s00_axi_wdata, // 16 8-bit samples
    input reg s00_axi_arid,
    input reg s00_axi_araddr,
    //input reg s00_axi_arlen,
    input reg s00_axi_arsize,
    input reg s00_axi_arburst,
    input reg s00_axi_arlock,
    input reg s00_axi_arcache,
    input reg s00_axi_arprot,
    input reg s00_axi_arregion,
    input reg s00_axi_arqos,
    input wire s00_axi_arvalid, //zero when reset
    output wire s00_axi_arready, //zero when reset
    output reg s00_axi_rresp,
    output reg s00_axi_rlast,
    output wire s00_axi_rvalid, //zero when reset
    input wire s00_axi_rready, //zero when reset
    output reg s00_axi_bid,
    output reg s00_axi_bresp,
    output wire s00_axi_bvalid, //zero when reset
    input wire s00_axi_bready, //zero when reset
    output wire [SDATA_WIDTH-1:0] s00_axi_rdata, // 16 8-bit samples
		
    input reg s01_axi_awid,
    input reg s01_axi_awaddr,
    //input reg s01_axi_awlen,
    input reg s01_axi_awsize,
    input reg s01_axi_awburst,
    input reg s01_axi_awlock,
    input reg s01_axi_awcache,
    input reg s01_axi_awprot,
    input reg s01_axi_awregion,
    input reg s01_axi_awqos,
    input wire s01_axi_awvalid, //zero when reset
    output wire s01_axi_awready, //zero when reset
    input reg s01_axi_wstrb,
    input reg s01_axi_wlast,
    input wire s01_axi_wvalid, //zero when reset
    output wire s01_axi_wready, //zero when reset
    input reg s01_axi_bid,
    input reg s01_axi_bresp,
    input wire s01_axi_bvalid, //zero when reset
    output wire s01_axi_bready, //zero when reset
    input wire [SDATA_WIDTH-1:0] s01_axi_wdata, // 16 8-bit samples
    input reg s01_axi_arid,
    input reg s01_axi_araddr,
    //input reg s01_axi_arlen,
    input reg s01_axi_arsize,
    input reg s01_axi_arburst,
    input reg s01_axi_arlock,
    input reg s01_axi_arcache,
    input reg s01_axi_arprot,
    input reg s01_axi_arregion,
    input reg s01_axi_arqos,
    input wire s01_axi_arvalid, //zero when reset
    output wire s01_axi_arready, //zero when reset
    output reg s01_axi_rresp,
    output reg s01_axi_rlast,
    output wire s01_axi_rvalid, //zero when reset
    input wire s01_axi_rready, //zero when reset
    output reg s01_axi_bid,
    output reg s01_axi_bresp,
    output wire s01_axi_bvalid, //zero when reset
    input wire s01_axi_bready, //zero when reset
    output wire [SDATA_WIDTH-1:0] s01_axi_rdata, // 16 8-bit samples
		
	input reg s21_axi_awid,
    input reg s21_axi_awaddr,
    //input reg s21_axi_awlen,
    input reg s21_axi_awsize,
    input reg s21_axi_awburst,
    input reg s21_axi_awlock,
    input reg s21_axi_awcache,
    input reg s21_axi_awprot,
    input reg s21_axi_awregion,
    input reg s21_axi_awqos,
    input wire s21_axi_awvalid, //zero when reset
    output wire s21_axi_awready, //zero when reset
    input reg s21_axi_wstrb,
    input reg s21_axi_wlast,
    input wire s21_axi_wvalid, //zero when reset
    output wire s21_axi_wready, //zero when reset
    input reg s21_axi_bid,
    input reg s21_axi_bresp,
    input wire s21_axi_bvalid, //zero when reset
    output wire s21_axi_bready, //zero when reset
    input wire [SDATA_WIDTH-1:0] s21_axi_wdata, // 16 8-bit samples
    input reg s21_axi_arid,
    input reg s21_axi_araddr,
    //input reg s21_axi_arlen,
    input reg s21_axi_arsize,
    input reg s21_axi_arburst,
    input reg s21_axi_arlock,
    input reg s21_axi_arcache,
    input reg s21_axi_arprot,
    input reg s21_axi_arregion,
    input reg s21_axi_arqos,
    input wire s21_axi_arvalid, //zero when reset
    output wire s21_axi_arready, //zero when reset
    output reg s21_axi_rresp,
    output reg s21_axi_rlast,
    output wire s21_axi_rvalid, //zero when reset
    input wire s21_axi_rready, //zero when reset
    output reg s21_axi_bid,
    output reg s21_axi_bresp,
    output wire s21_axi_bvalid, //zero when reset
    input wire s21_axi_bready, //zero when reset
    output wire [SDATA_WIDTH-1:0] s21_axi_rdata, // 16 8-bit samples
		
    input reg s20_axi_awid,
    input reg s20_axi_awaddr,
    //input reg s20_axi_awlen,
    input reg s20_axi_awsize,
    input reg s20_axi_awburst,
    input reg s20_axi_awlock,
    input reg s20_axi_awcache,
    input reg s20_axi_awprot,
    input reg s20_axi_awregion,
    input reg s20_axi_awqos,
    input wire s20_axi_awvalid, //zero when reset
    output wire s20_axi_awready, //zero when reset
    input reg s20_axi_wstrb,
    input reg s20_axi_wlast,
    input wire s20_axi_wvalid, //zero when reset
    output wire s20_axi_wready, //zero when reset
    input reg s20_axi_bid,
    input reg s20_axi_bresp,
    input wire s20_axi_bvalid, //zero when reset
    output wire s20_axi_bready, //zero when reset
    input wire [SDATA_WIDTH-1:0] s20_axi_wdata, // 16 8-bit samples
    input reg s20_axi_arid,
    input reg s20_axi_araddr,
    //input reg s20_axi_arlen,
    input reg s20_axi_arsize,
    input reg s20_axi_arburst,
    input reg s20_axi_arlock,
    input reg s20_axi_arcache,
    input reg s20_axi_arprot,
    input reg s20_axi_arregion,
    input reg s20_axi_arqos,
    input wire s20_axi_arvalid, //zero when reset
    output wire s20_axi_arready, //zero when reset
    output reg s20_axi_rresp,
    output reg s20_axi_rlast,
    output wire s20_axi_rvalid, //zero when reset
    input wire s20_axi_rready, //zero when reset
    output reg s20_axi_bid,
    output reg s20_axi_bresp,
    output wire s20_axi_bvalid, //zero when reset
    input wire s20_axi_bready, //zero when reset
    output wire [SDATA_WIDTH-1:0] s20_axi_rdata, // 16 8-bit samples
	
    output reg m00_axi_awid,
    output reg m00_axi_awaddr,
    //output reg m00_axi_awlen,
    output reg m00_axi_awsize,
    output reg m00_axi_awburst,
    output reg m00_axi_awlock,
    output reg m00_axi_awcache,
    output reg m00_axi_awprot,
    output reg m00_axi_awregion,
    output reg m00_axi_awqos,
    output wire m00_axi_awvalid, //zero when reset
    input wire m00_axi_awready, //zero when reset
    output reg m00_axi_wstrb,
    output reg m00_axi_wlast,
    output wire m00_axi_wvalid, //zero when reset
    input wire m00_axi_wready, //zero when reset
    output reg m00_axi_bid,
    output reg m00_axi_bresp,
    output wire m00_axi_bvalid, //zero when reset
    input wire m00_axi_bready, //zero when reset
    output wire [MDATA_WIDTH-1:0] m00_axi_wdata, // 16 8-bit samples
    output reg m00_axi_arid,
    output reg m00_axi_araddr,
    //output reg m00_axi_arlen,
    output reg m00_axi_arsize,
    output reg m00_axi_arburst,
    output reg m00_axi_arlock,
    output reg m00_axi_arcache,
    output reg m00_axi_arprot,
    output reg m00_axi_arregion,
    output reg m00_axi_arqos,
    output wire m00_axi_arvalid, //zero when reset
    input wire m00_axi_arready, //zero when reset
    input reg m00_axi_rresp,
    input reg m00_axi_rlast,
    input wire m00_axi_rvalid, //zero when reset
    output wire m00_axi_rready, //zero when reset
    input reg m00_axi_bid,
    input reg m00_axi_bresp,
    input wire m00_axi_bvalid, //zero when reset
    output wire m00_axi_bready, //zero when reset
    input wire [MDATA_WIDTH-1:0] m00_axi_rdata, // 16 8-bit samples

    output reg m01_axi_awid,
    output reg m01_axi_awaddr,
    //output reg m01_axi_awlen,
    output reg m01_axi_awsize,
    output reg m01_axi_awburst,
    output reg m01_axi_awlock,
    output reg m01_axi_awcache,
    output reg m01_axi_awprot,
    output reg m01_axi_awregion,
    output reg m01_axi_awqos,
    output wire m01_axi_awvalid, //zero when reset
    input wire m01_axi_awready, //zero when reset
    output reg m01_axi_wstrb,
    output reg m01_axi_wlast,
    output wire m01_axi_wvalid, //zero when reset
    input wire m01_axi_wready, //zero when reset
    output reg m01_axi_bid,
    output reg m01_axi_bresp,
    output wire m01_axi_bvalid, //zero when reset
    input wire m01_axi_bready, //zero when reset
    output wire [MDATA_WIDTH-1:0] m01_axi_wdata, // 16 8-bit samples
    output reg m01_axi_arid,
    output reg m01_axi_araddr,
    //output reg m01_axi_arlen,
    output reg m01_axi_arsize,
    output reg m01_axi_arburst,
    output reg m01_axi_arlock,
    output reg m01_axi_arcache,
    output reg m01_axi_arprot,
    output reg m01_axi_arregion,
    output reg m01_axi_arqos,
    output wire m01_axi_arvalid, //zero when reset
    input wire m01_axi_arready, //zero when reset
    input reg m01_axi_rresp,
    input reg m01_axi_rlast,
    input wire m01_axi_rvalid, //zero when reset
    output wire m01_axi_rready, //zero when reset
    input reg m01_axi_bid,
    input reg m01_axi_bresp,
    input wire m01_axi_bvalid, //zero when reset
    output wire m01_axi_bready, //zero when reset
    input wire [MDATA_WIDTH-1:0] m01_axi_rdata, // 16 8-bit samples

    output reg m21_axi_awid,
    output reg m21_axi_awaddr,
    //output reg m21_axi_awlen,
    output reg m21_axi_awsize,
    output reg m21_axi_awburst,
    output reg m21_axi_awlock,
    output reg m21_axi_awcache,
    output reg m21_axi_awprot,
    output reg m21_axi_awregion,
    output reg m21_axi_awqos,
    output wire m21_axi_awvalid, //zero when reset
    input wire m21_axi_awready, //zero when reset
    output reg m21_axi_wstrb,
    output reg m21_axi_wlast,
    output wire m21_axi_wvalid, //zero when reset
    input wire m21_axi_wready, //zero when reset
    output reg m21_axi_bid,
    output reg m21_axi_bresp,
    output wire m21_axi_bvalid, //zero when reset
    input wire m21_axi_bready, //zero when reset
    output wire [MDATA_WIDTH-1:0] m21_axi_wdata, // 16 8-bit samples
    output reg m21_axi_arid,
    output reg m21_axi_araddr,
    //output reg m21_axi_arlen,
    output reg m21_axi_arsize,
    output reg m21_axi_arburst,
    output reg m21_axi_arlock,
    output reg m21_axi_arcache,
    output reg m21_axi_arprot,
    output reg m21_axi_arregion,
    output reg m21_axi_arqos,
    output wire m21_axi_arvalid, //zero when reset
    input wire m21_axi_arready, //zero when reset
    input reg m21_axi_rresp,
    input reg m21_axi_rlast,
    input wire m21_axi_rvalid, //zero when reset
    output wire m21_axi_rready, //zero when reset
    input reg m21_axi_bid,
    input reg m21_axi_bresp,
    input wire m21_axi_bvalid, //zero when reset
    output wire m21_axi_bready, //zero when reset
    input wire [MDATA_WIDTH-1:0] m21_axi_rdata, // 16 8-bit samples
    
    output reg m20_axi_awid,
    output reg m20_axi_awaddr,
    //output reg m20_axi_awlen,
    output reg m20_axi_awsize,
    output reg m20_axi_awburst,
    output reg m20_axi_awlock,
    output reg m20_axi_awcache,
    output reg m20_axi_awprot,
    output reg m20_axi_awregion,
    output reg m20_axi_awqos,
    output wire m20_axi_awvalid, //zero when reset
    input wire m20_axi_awready, //zero when reset
    output reg m20_axi_wstrb,
    output reg m20_axi_wlast,
    output wire m20_axi_wvalid, //zero when reset
    input wire m20_axi_wready, //zero when reset
    output reg m20_axi_bid,
    output reg m20_axi_bresp,
    output wire m20_axi_bvalid, //zero when reset
    input wire m20_axi_bready, //zero when reset
    output wire [MDATA_WIDTH-1:0] m20_axi_wdata, // 16 8-bit samples
    output reg m20_axi_arid,
    output reg m20_axi_araddr,
    //output reg m20_axi_arlen,
    output reg m20_axi_arsize,
    output reg m20_axi_arburst,
    output reg m20_axi_arlock,
    output reg m20_axi_arcache,
    output reg m20_axi_arprot,
    output reg m20_axi_arregion,
    output reg m20_axi_arqos,
    output wire m20_axi_arvalid, //zero when reset
    input wire m20_axi_arready, //zero when reset
    input reg m20_axi_rresp,
    input reg m20_axi_rlast,
    input wire m20_axi_rvalid, //zero when reset
    output wire m20_axi_rready, //zero when reset
    input reg m20_axi_bid,
    input reg m20_axi_bresp,
    input wire m20_axi_bvalid, //zero when reset
    output wire m20_axi_bready, //zero when reset
    input wire [MDATA_WIDTH-1:0] m20_axi_rdata // 16 8-bit samples
    );

    integer samples = SDATA_WIDTH/SSAMPLE_WIDTH;
    integer i;
    
    always @(posedge CLK)
        begin
            if (resetn == 1'b0) //~resetn
            begin
            // data out, valid, and wlast should all be 0
            m00_axis_wdata <= 0;
            m00_axi_wlast <= 0;
		    m01_axis_wdata <= 0;
            m01_axi_wlast <= 0;
		    m20_axis_wdata <= 0;
            m20_axi_wlast <= 0;
		    m21_axis_wdata <= 0;
            m21_axi_wlast <= 0;

		    // write
		    m00_axi_rvalid <= 0;
		    m01_axi_rvalid <= 0;
		    m20_axi_rvalid <= 0;
	  	    m21_axi_rvalid <= 0;
		    s00_axi_wready <= 0;
		    s01_axi_wready <= 0;
		    s20_axi_wready <= 0;
		    s21_axi_wready <= 0;
            end
            else begin
		/*---------------------------- CHANNEL 00: ADC A ----------------------------*/
		if(m00_axi_rready && s00_axi_wvalid) begin
			// input wready goes high (wready = 1'b1)
	   		m00_axi_rlast <= s00_axi_wlast;
			// wvalid is now high (wvalid = 1'b1)
            m00_axi_rvalid <= 1'b1;
			// this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
            for(i=0; i<samples; i = i+1) begin
				m00_axi_rdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= s00_axi_wdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
			end
		end 
		else begin 
            // invalid data, so output data is set to static value of 0
            m00_axi_rdata <= 128'd0;

			// output valid(s) should be low
            m00_axi_rvalid = 0;
       end
		/*---------------------------- CHANNEL 01: ADC B ----------------------------*/
		if(m01_axi_rready && s01_axi_wvalid) begin
			// input wready goes high (wready = 1'b1)
	   		m01_axi_rlast <= s01_axi_wlast;
			// wvalid is now high (wvalid = 1'b1)
			m01_axi_rvalid <= 1'b1;
			// this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
            for(i=0; i<samples; i = i+1) begin
				m01_axi_rdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= s01_axi_wdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
			end
		end 
		else begin 
            // invalid data, so output data is set to static value of 0
            m01_axi_rdata <= 128'd0;

			// output valid(s) should be low
            m01_axi_rvalid = 0;
        end
		/*---------------------------- CHANNEL 20: ADC C ----------------------------*/  
		if(m20_axi_rready && s20_axi_wvalid) begin
			// input wready goes high (wready = 1'b1)
		  	m20_axi_rlast <= s20_axi_wlast;
			// wvalid is now high (wvalid = 1'b1)
			m20_axi_rvalid <= 1'b1;
			// this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
            for(i=0; i<samples; i = i+1) begin
				m20_axi_rdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= s20_axi_wdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
			end
		end 
		else begin 
            // invalid data, so output data is set to static value of 0
            m20_axi_rdata <= 128'd0;

			// output valid(s) should be low
            m20_axi_rvalid = 0;
        end
		/*---------------------------- CHANNEL 21: ADC D ----------------------------*/
		if(m21_axi_rready && s21_axi_wvalid) begin
			// input wready goes high (wready = 1'b1)
		   	m21_axi_rlast <= s21_axi_wlast;
			// wvalid is now high (wvalid = 1'b1)
			m21_axi_rvalid <= 1'b1;
			// this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
            for(i=0; i<samples; i = i+1) begin
				m21_axi_rdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= s21_axi_wdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
			end
		end 
        else begin 
            // invalid data, so output data is set to static value of 0
            m21_axi_rdata <= 128'd0;

			// output valid(s) should be low
            m21_axi_rvalid = 0;
            end
	    end
    end
endmodule
