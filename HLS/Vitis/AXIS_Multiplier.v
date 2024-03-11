/* 
 * AXI stream multiplier block taking 128-bit input data and 8-bit beamforming weight to apply to data
*/
module axis_multiplier
  #(
    parameter SDATA_WIDTH = 128,
    parameter SSAMPLE_WIDTH = 8,
    parameter WEIGHT_WIDTH = 8
   ) 
    (
    input wire CLK,
    input wire resetn,
    
    /* all axis prefixed variables should be inferred per UG994 because of the 
     * use of the AXI standard naming convention */

    input wire s_axis_tvalid,
    output reg s_axis_tready,
    input wire [SDATA_WIDTH-1:0] s_axis_tdata, // 16 8-bit samples
    input wire s_axis_tlast,

    input [WEIGHT_WIDTH:0] bWeight, // this will be the multiplication factor for all 16 samples, should be <1

    output reg [MDATA_WIDTH-1:0] m_axis_s2mm_tdata,
    output reg [SDATA_WIDTH/SSAMPLE_WIDTH-1:0] m_axis_s2mm_tkeep,
    output reg m_axis_s2mm_tlast,
    input wire m_axis_s2mm_tready,
    output reg m_axis_s2mm_tvalid);

    parameter MSAMPLE_WIDTH = SSAMPLE_WIDTH + WEIGHT_WIDTH;
    parameter SAMPLES = SDATA_WIDTH/SSAMPLE_WIDTH;
    parameter MDATA_WIDTH = MSAMPLE_WIDTH*SAMPLES;

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


                        // this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
                        for(i=0; i<SAMPLES; i++) begin

                            // this can be a non-blocking assignment because there is a blocking assignment in the incrementing of i
                            m_axis_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= bWeight * s_axis_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
                            
                        end
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
