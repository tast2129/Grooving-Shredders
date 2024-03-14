/* 
 * AXI stream multiplier block taking 128-bit input data and 8-bit beamforming weight to apply to data
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

    input reg s_axi_awid,
    input reg s_axi_awaddr,
    input reg s_axi_awlen,
    input reg s_axi_awsize,
    input reg s_axi_awburst,
    input reg s_axi_awlock,
    input reg s_axi_awcache,
    input reg s_axi_awprot,
    input reg s_axi_awregion,
    input reg s_axi_awqos,
    input reg s_axi_awvalid,
    input wire [SDATA_WIDTH-1:0] s_axi_tdata, // 16 8-bit samples
    input wire s_axi_tlast,

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
