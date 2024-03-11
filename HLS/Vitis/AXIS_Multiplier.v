/* 128-bit input multiplier block with axi stream inputs */

module axis_multiplier #(
    parameter DATA_WIDTH = 128,
    parameter WEIGHT_WIDTH = 8
) (
    input wire CLK,
    input wire resetn,
    /* all axis prefixed variables should be inferred per UG994 because of the 
     * use of the AXI standard naming convention */

    input wire s_axis_tvalid,
    output wire s_axis_tready,
    input wire [DATA_WIDTH-1:0] s_axis_tdata, // 16 8-bit samples
    input wire s_axis_tlast,

    input [WEIGHT_WIDTH:0] bWeight, // this will be the multiplication factor for all 16 samples, should be <1

    output reg [DATA_WIDTH-1:0] m_axis_s2mm_tdata,
    output reg [DATA_WIDTH/8-1:0] m_axis_s2mm_tkeep,
    output reg m_axis_s2mm_tlast,
    input wire m_axis_s2mm_tready,
    output reg m_axis_s2mm_tvalid);

    integer i;
    
    always @(posedge CLK)
        begin
            if (resetn == 1'b0) //~resetn
                begin
                    // data out should be 0
                    m_axis_s2mm_tdata = 0;
                    // valid should be 0
                    m_axis_s2mm_tvalid = 0;
                    // we should not be ready (so 0)
                    m_axis_s2mm_tready = 0;
                    // tlast is also 0
                    m_axis_s2mm_tlast = 0;
                end
            else
                begin
                    // ready goes high tready = 1'b1
                    m_axis_s2mm_tlast <= s_axis_tlast 
                    if(m_axis_s2mm_tready && s_axis_tvalid) begin
                        // tkeep is now high (tkeep = 16'hffff)
                        // tvalid is now high (tvalid = 1'b1)

                        // this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
                        for(i=0; i<(8*16); i=i+8) begin
                            // this can be a non-blocking assignment because there is a blocking assignment in the incrementing of i
                            m_axis_s2mm_tdata[(i+7):i] <= bWeight * s_axis_tdata[(i+7):i]; // syntax change!
                            // we need to take bit growth into account
                            // when we multiply bits add
                            // two options
                                // option1: use full precision (2x bits) and dma all the data 
                                // option2: truncate/round to for bit reduction 
                                    // bweight is 8 bits, data is 16bits, output fp is 24 bits 
                        end
                        end
                        // s_axis_s2mm_tready = m_axis_tready;
                    else
                        begin
                            // things either stay the same,
                            // e.g., tdata <= tdata,
                            // or they can be set to some static value
                            // e.g., tdata <= 128'd0
                            // but output valid should be low
                            // output tkeep should be low too

                        end
                end
    end
    
endmodule
