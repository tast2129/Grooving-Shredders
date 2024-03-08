/* 128-bit input multiplier block with axi stream inputs */

module axis_multiplier (
    input CLK,
    /* all axis prefixed variables should be inferred per UG994 because of the 
     * use of the AXI standard naming convention */
    input wire m_axis_tvalid,
    input wire m_axis_tready,
    input wire [127:0] m_axis_tdata, // 16 8-bit samples
    input wire m_axis_tlast,
    input [7:0] bWeight, // this will be the multiplication factor for all 16 samples, should be <1
    output [127:0] s_axis_s2mm_tdata,
    output [15:0] s_axis_s2mm_tkeep,
    output s_axis_s2mm_tlast,
    output s_axis_s2mm_tready,
    output s_axis_s2mm_tvalid);

    integer i;
    
    assign s_axis_s2mm_tvalid = m_axis_tvalid;
    assign s_axis_s2mm_tready = m_axis_tready; // should I only be updating this after the multiplication operation is complete?
    
    assign s_axis_s2mm_tlast =  m_axis_tlast;
    
    
    always @(posedge CLK)
        begin
            if(m_axis_tready) begin
                // this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
                for(i=0; i<(8*16); i=i+8) begin
                    // this can be a non-blocking assignment because there is a blocking assignment in the incrementing of i
                    s_axis_s2mm_tdata[(i+7):i] <= bWeight * m_axis_tdata[(i+7):i];
                end
                // alternatively...
                /*
                s_axis_s2mm_tdata[7:0] <= bWeight * m_axis_tdata[7:0];
                s_axis_s2mm_tdata[15:8] <= bWeight * m_axis_tdata[15:8];
                s_axis_s2mm_tdata[23:16] <= bWeight * m_axis_tdata[23:16];
                s_axis_s2mm_tdata[31:24] <= bWeight * m_axis_tdata[31:24];
                s_axis_s2mm_tdata[39:32] <= bWeight * m_axis_tdata[39:32];
                s_axis_s2mm_tdata[47:40] <= bWeight * m_axis_tdata[47:40];
                s_axis_s2mm_tdata[55:48] <= bWeight * m_axis_tdata[55:48];
                s_axis_s2mm_tdata[63:56] <= bWeight * m_axis_tdata[63:56];
                s_axis_s2mm_tdata[71:64] <= bWeight * m_axis_tdata[71:64];
                s_axis_s2mm_tdata[79:72] <= bWeight * m_axis_tdata[79:72];
                s_axis_s2mm_tdata[87:80] <= bWeight * m_axis_tdata[87:80];
                s_axis_s2mm_tdata[95:88] <= bWeight * m_axis_tdata[95:88];
                s_axis_s2mm_tdata[103:96] <= bWeight * m_axis_tdata[103:96];
                s_axis_s2mm_tdata[111:104] <= bWeight * m_axis_tdata[111:104];
                s_axis_s2mm_tdata[119:112] <= bWeight * m_axis_tdata[119:112];
                s_axis_s2mm_tdata[128:120] <= bWeight * m_axis_tdata[128:120];
                */
            end
        end
endmodule
