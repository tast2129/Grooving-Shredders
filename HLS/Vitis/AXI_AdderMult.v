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
    input clock,
    input resetn,

    // these will be the multiplication factor for all 16 samples in each channel, each should be <1
    input [WEIGHT_WIDTH-1:0] bWeight00_imag, input [WEIGHT_WIDTH-1:0] bWeight00_real,
    input [WEIGHT_WIDTH-1:0] bWeight01_imag, input [WEIGHT_WIDTH-1:0] bWeight01_real,
    input [WEIGHT_WIDTH-1:0] bWeight20_imag, input [WEIGHT_WIDTH-1:0] bWeight20_real,
    input [WEIGHT_WIDTH-1:0] bWeight21_imag, input [WEIGHT_WIDTH-1:0] bWeight21_real,
    
    /* all axis prefixed variables should be inferred per UG994 because of the 
     * use of the AXI standard naming convention */

    input [5:0]             s00_axi_awid,
    input [48:0]            s00_axi_awaddr,
    input [7:0]             s00_axi_awlen,
    input [2:0]             s00_axi_awsize,
    input [1:0]             s00_axi_awburst,
    input                   s00_axi_awlock,
    input [3:0]             s00_axi_awcache,
    input [2:0]             s00_axi_awprot,
    input                   s00_axi_awregion,
    input [3:0]             s00_axi_awqos,
    input                   s00_axi_awvalid, //zero when reset
    output                  s00_axi_awready, //zero when reset
    input [15:0]            s00_axi_wstrb,
    input                   s00_axi_wlast,
    input                   s00_axi_wvalid, //zero when reset
    output                  s00_axi_wready, //zero when reset
    input [5:0]             s00_axi_bid,
    input [1:0]             s00_axi_bresp,
    input                   s00_axi_bvalid, //zero when reset
    output                  s00_axi_bready, //zero when reset
    input [SDATA_WIDTH-1:0] s00_axi_wdata, // 16 8-bit samples
    input [5:0]             s00_axi_arid,
    input [48:0]            s00_axi_araddr,
    input [7:0]             s00_axi_arlen,
    input [2:0]             s00_axi_arsize,
    input [1:0]             s00_axi_arburst,
    input                   s00_axi_arlock,
    input [3:0]             s00_axi_arcache,
    input [2:0]             s00_axi_arprot,
    input                   s00_axi_arregion,
    input [3:0]             s00_axi_arqos,
    input                   s00_axi_arvalid, //zero when reset
    output                  s00_axi_arready, //zero when reset
    output [1:0]            s00_axi_rresp,
    output                  s00_axi_rlast,
    output                  s00_axi_rvalid, //zero when reset
    input                   s00_axi_rready, //zero when reset
    output[SDATA_WIDTH-1:0] s00_axi_rdata, // 16 8-bit samples
		
    input [5:0]             s01_axi_awid,
    input [48:0]            s01_axi_awaddr,
    input [7:0]             s01_axi_awlen,
    input [2:0]             s01_axi_awsize,
    input [1:0]             s01_axi_awburst,
    input                   s01_axi_awlock,
    input [3:0]             s01_axi_awcache,
    input [2:0]             s01_axi_awprot,
    input                   s01_axi_awregion,
    input [3:0]             s01_axi_awqos,
    input                   s01_axi_awvalid, //zero when reset
    output                  s01_axi_awready, //zero when reset
    input [15:0]            s01_axi_wstrb,
    input                   s01_axi_wlast,
    input                   s01_axi_wvalid, //zero when reset
    output                  s01_axi_wready, //zero when reset
    input [5:0]             s01_axi_bid,
    input [1:0]             s01_axi_bresp,
    input                   s01_axi_bvalid, //zero when reset
    output                  s01_axi_bready, //zero when reset
    input [SDATA_WIDTH-1:0] s01_axi_wdata, // 16 8-bit samples
    input [5:0]             s01_axi_arid,
    input [48:0]            s01_axi_araddr,
    input [7:0]             s01_axi_arlen,
    input [2:0]             s01_axi_arsize,
    input [1:0]             s01_axi_arburst,
    input                   s01_axi_arlock,
    input [3:0]             s01_axi_arcache,
    input [2:0]             s01_axi_arprot,
    input                   s01_axi_arregion,
    input [3:0]             s01_axi_arqos,
    input                   s01_axi_arvalid, //zero when reset
    output                  s01_axi_arready, //zero when reset
    output [1:0]            s01_axi_rresp,
    output                  s01_axi_rlast,
    output                  s01_axi_rvalid, //zero when reset
    input                   s01_axi_rready, //zero when reset
    output[SDATA_WIDTH-1:0] s01_axi_rdata, // 16 8-bit samples
		
    input [5:0]             s21_axi_awid,
    input [48:0]            s21_axi_awaddr,
    input [7:0]             s21_axi_awlen,
    input [2:0]             s21_axi_awsize,
    input [1:0]             s21_axi_awburst,
    input                   s21_axi_awlock,
    input [3:0]             s21_axi_awcache,
    input [2:0]             s21_axi_awprot,
    input                   s21_axi_awregion,
    input [3:0]             s21_axi_awqos,
    input                   s21_axi_awvalid, //zero when reset
    output                  s21_axi_awready, //zero when reset
    input [15:0]            s21_axi_wstrb,
    input                   s21_axi_wlast,
    input                   s21_axi_wvalid, //zero when reset
    output                  s21_axi_wready, //zero when reset
    input [5:0]             s21_axi_bid,
    input [1:0]             s21_axi_bresp,
    input                   s21_axi_bvalid, //zero when reset
    output                  s21_axi_bready, //zero when reset
    input [SDATA_WIDTH-1:0] s21_axi_wdata, // 16 8-bit samples
    input [5:0]             s21_axi_arid,
    input [48:0]            s21_axi_araddr,
    input [7:0]             s21_axi_arlen,
    input [2:0]             s21_axi_arsize,
    input [1:0]             s21_axi_arburst,
    input                   s21_axi_arlock,
    input [3:0]             s21_axi_arcache,
    input [2:0]             s21_axi_arprot,
    input                   s21_axi_arregion,
    input [3:0]             s21_axi_arqos,
    input                   s21_axi_arvalid, //zero when reset
    output                  s21_axi_arready, //zero when reset
    output [1:0]            s21_axi_rresp,
    output                  s21_axi_rlast,
    output                  s21_axi_rvalid, //zero when reset
    input                   s21_axi_rready, //zero when reset
    output[SDATA_WIDTH-1:0] s21_axi_rdata, // 16 8-bit samples
		
    input [5:0]             s20_axi_awid,
    input [48:0]            s20_axi_awaddr,
    input [7:0]             s20_axi_awlen,
    input [2:0]             s20_axi_awsize,
    input [1:0]             s20_axi_awburst,
    input                   s20_axi_awlock,
    input [3:0]             s20_axi_awcache,
    input [2:0]             s20_axi_awprot,
    input                   s20_axi_awregion,
    input [3:0]             s20_axi_awqos,
    input                   s20_axi_awvalid, //zero when reset
    output                  s20_axi_awready, //zero when reset
    input [15:0]            s20_axi_wstrb,
    input                   s20_axi_wlast,
    input                   s20_axi_wvalid, //zero when reset
    output                  s20_axi_wready, //zero when reset
    input [5:0]             s20_axi_bid,
    input [1:0]             s20_axi_bresp,
    input                   s20_axi_bvalid, //zero when reset
    output                  s20_axi_bready, //zero when reset
    input [SDATA_WIDTH-1:0] s20_axi_wdata, // 16 8-bit samples
    input [5:0]             s20_axi_arid,
    input [48:0]            s20_axi_araddr,
    input [7:0]             s20_axi_arlen,
    input [2:0]             s20_axi_arsize,
    input [1:0]             s20_axi_arburst,
    input                   s20_axi_arlock,
    input [3:0]             s20_axi_arcache,
    input [2:0]             s20_axi_arprot,
    input                   s20_axi_arregion,
    input [3:0]             s20_axi_arqos,
    input                   s20_axi_arvalid, //zero when reset
    output                  s20_axi_arready, //zero when reset
    output [1:0]            s20_axi_rresp,
    output                  s20_axi_rlast,
    output                  s20_axi_rvalid, //zero when reset
    input                   s20_axi_rready, //zero when reset
    output[SDATA_WIDTH-1:0] s20_axi_rdata, // 16 8-bit samples
	
    output [5:0]            m00_axi_awid,
    output [48:0]           m00_axi_awaddr,
    output [7:0]            m00_axi_awlen,
    output [2:0]            m00_axi_awsize,
    output [1:0]            m00_axi_awburst,
    output                  m00_axi_awlock,
    output [3:0]            m00_axi_awcache,
    output [2:0]            m00_axi_awprot,
    output                  m00_axi_awregion,
    output [3:0]            m00_axi_awqos,
    output                  m00_axi_awvalid, //zero when reset
    input                   m00_axi_awready, //zero when reset
    output [15:0]           m00_axi_wstrb,
    output                  m00_axi_wlast,
    output                  m00_axi_wvalid, //zero when reset
    input                   m00_axi_wready, //zero when reset
    output[MDATA_WIDTH-1:0] m00_axi_wdata, // 16 8-bit samples
    output [5:0]            m00_axi_arid,
    output [48:0]           m00_axi_araddr,
    output [7:0]            m00_axi_arlen,
    output [2:0]            m00_axi_arsize,
    output [1:0]            m00_axi_arburst,
    output                  m00_axi_arlock,
    output [3:0]            m00_axi_arcache,
    output [2:0]            m00_axi_arprot,
    output                  m00_axi_arregion,
    output [3:0]            m00_axi_arqos,
    output                  m00_axi_arvalid, //zero when reset
    input                   m00_axi_arready, //zero when reset
    input  [1:0]            m00_axi_rresp,
    input                   m00_axi_rlast,
    input                   m00_axi_rvalid, //zero when reset
    output                  m00_axi_rready, //zero when reset
    input  [5:0]            m00_axi_bid,
    input  [1:0]            m00_axi_bresp,
    input                   m00_axi_bvalid, //zero when reset
    output                  m00_axi_bready, //zero when reset
    input [MDATA_WIDTH-1:0] m00_axi_rdata, // 16 8-bit samples

    output [5:0]            m01_axi_awid,
    output [48:0]           m01_axi_awaddr,
    output [7:0]            m01_axi_awlen,
    output [2:0]            m01_axi_awsize,
    output [1:0]            m01_axi_awburst,
    output                  m01_axi_awlock,
    output [3:0]            m01_axi_awcache,
    output [2:0]            m01_axi_awprot,
    output                  m01_axi_awregion,
    output [3:0]            m01_axi_awqos,
    output                  m01_axi_awvalid, //zero when reset
    input                   m01_axi_awready, //zero when reset
    output [15:0]           m01_axi_wstrb,
    output                  m01_axi_wlast,
    output                  m01_axi_wvalid, //zero when reset
    input                   m01_axi_wready, //zero when reset
    output[MDATA_WIDTH-1:0] m01_axi_wdata, // 16 8-bit samples
    output [5:0]            m01_axi_arid,
    output [48:0]           m01_axi_araddr,
    output [7:0]            m01_axi_arlen,
    output [2:0]            m01_axi_arsize,
    output [1:0]            m01_axi_arburst,
    output                  m01_axi_arlock,
    output [3:0]            m01_axi_arcache,
    output [2:0]            m01_axi_arprot,
    output                  m01_axi_arregion,
    output [3:0]            m01_axi_arqos,
    output                  m01_axi_arvalid, //zero when reset
    input                   m01_axi_arready, //zero when reset
    input  [1:0]            m01_axi_rresp,
    input                   m01_axi_rlast,
    input                   m01_axi_rvalid, //zero when reset
    output                  m01_axi_rready, //zero when reset
    input  [5:0]            m01_axi_bid,
    input  [1:0]            m01_axi_bresp,
    input                   m01_axi_bvalid, //zero when reset
    output                  m01_axi_bready, //zero when reset
    input [MDATA_WIDTH-1:0] m01_axi_rdata, // 16 8-bit samples

    output [5:0]            m21_axi_awid,
    output [48:0]           m21_axi_awaddr,
    output [7:0]            m21_axi_awlen,
    output [2:0]            m21_axi_awsize,
    output [1:0]            m21_axi_awburst,
    output                  m21_axi_awlock,
    output [3:0]            m21_axi_awcache,
    output [2:0]            m21_axi_awprot,
    output                  m21_axi_awregion,
    output [3:0]            m21_axi_awqos,
    output                  m21_axi_awvalid, //zero when reset
    input                   m21_axi_awready, //zero when reset
    output [15:0]           m21_axi_wstrb,
    output                  m21_axi_wlast,
    output                  m21_axi_wvalid, //zero when reset
    input                   m21_axi_wready, //zero when reset
    output[MDATA_WIDTH-1:0] m21_axi_wdata, // 16 8-bit samples
    output [5:0]            m21_axi_arid,
    output [48:0]           m21_axi_araddr,
    output [7:0]            m21_axi_arlen,
    output [2:0]            m21_axi_arsize,
    output [1:0]            m21_axi_arburst,
    output                  m21_axi_arlock,
    output [3:0]            m21_axi_arcache,
    output [2:0]            m21_axi_arprot,
    output                  m21_axi_arregion,
    output [3:0]            m21_axi_arqos,
    output                  m21_axi_arvalid, //zero when reset
    input                   m21_axi_arready, //zero when reset
    input  [1:0]            m21_axi_rresp,
    input                   m21_axi_rlast,
    input                   m21_axi_rvalid, //zero when reset
    output                  m21_axi_rready, //zero when reset
    input  [5:0]            m21_axi_bid,
    input  [1:0]            m21_axi_bresp,
    input                   m21_axi_bvalid, //zero when reset
    output                  m21_axi_bready, //zero when reset
    input [MDATA_WIDTH-1:0] m21_axi_rdata, // 16 8-bit samples
    
    output [5:0]            m20_axi_awid,
    output [48:0]           m20_axi_awaddr,
    output [7:0]            m20_axi_awlen,
    output [2:0]            m20_axi_awsize,
    output [1:0]            m20_axi_awburst,
    output                  m20_axi_awlock,
    output [3:0]            m20_axi_awcache,
    output [2:0]            m20_axi_awprot,
    output                  m20_axi_awregion,
    output [3:0]            m20_axi_awqos,
    output                  m20_axi_awvalid, //zero when reset
    input                   m20_axi_awready, //zero when reset
    output [15:0]           m20_axi_wstrb,
    output                  m20_axi_wlast,
    output                  m20_axi_wvalid, //zero when reset
    input                   m20_axi_wready, //zero when reset
    output[MDATA_WIDTH-1:0] m20_axi_wdata, // 16 8-bit samples
    output [5:0]            m20_axi_arid,
    output [48:0]           m20_axi_araddr,
    output [7:0]            m20_axi_arlen,
    output [2:0]            m20_axi_arsize,
    output [1:0]            m20_axi_arburst,
    output                  m20_axi_arlock,
    output [3:0]            m20_axi_arcache,
    output [2:0]            m20_axi_arprot,
    output                  m20_axi_arregion,
    output [3:0]            m20_axi_arqos,
    output                  m20_axi_arvalid, //zero when reset
    input                   m20_axi_arready, //zero when reset
    input  [1:0]            m20_axi_rresp,
    input                   m20_axi_rlast,
    input                   m20_axi_rvalid, //zero when reset
    output                  m20_axi_rready, //zero when reset
    input  [5:0]            m20_axi_bid,
    input  [1:0]            m20_axi_bresp,
    input                   m20_axi_bvalid, //zero when reset
    output                  m20_axi_bready, //zero when reset
    input [MDATA_WIDTH-1:0] m20_axi_rdata // 16 8-bit samples
    );

    integer samples = SDATA_WIDTH/SSAMPLE_WIDTH;
    integer i;
    
    always @(posedge CLK) begin
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
	 	//---------------------------- CHANNEL 00: ADC D ----------------------------
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
		
		//---------------------------- CHANNEL 01: ADC C ----------------------------
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
		
		//---------------------------- CHANNEL 20: ADC B ---------------------------- 
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
		//---------------------------- CHANNEL 21: ADC A ----------------------------
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
