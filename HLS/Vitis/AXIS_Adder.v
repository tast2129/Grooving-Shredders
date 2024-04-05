/* 
 * AXI stream multiplier block taking 128-bit input data and 8-bit beamforming weight to apply to data
*/
module axis_adder
  #(
    parameter SDATA_WIDTH = 128,
    parameter SSAMPLE_WIDTH = 8,
    parameter WEIGHT_WIDTH = 8,
    parameter MSAMPLE_WIDTH = 16,   // SSAMPLE_WIDTH + WEIGHT_WIDTH
    parameter MDATA_WIDTH = 256     // MSAMPLE_WIDTH * SAMPLES
   ) 
    (
    input wire clock,
    input wire resetn,

    // this will be the multiplication factor for all 16 samples in its channel, should be <1
    input [WEIGHT_WIDTH:0] bWeight00_real,
    input [WEIGHT_WIDTH:0] bWeight00_imag,
    input [WEIGHT_WIDTH:0] bWeight01_real,
    input [WEIGHT_WIDTH:0] bWeight01_imag,
    input [WEIGHT_WIDTH:0] bWeight20_real,
    input [WEIGHT_WIDTH:0] bWeight20_imag,
    input [WEIGHT_WIDTH:0] bWeight21_real,
    input [WEIGHT_WIDTH:0] bWeight21_imag,
    
    /* all axis prefixed variables should be inferred per UG994 because of the 
     * use of the AXI standard naming convention */
    input wire s00_axis_tvalid,
    output reg s00_axis_tready,
    input wire [SDATA_WIDTH-1:0] s00_axis_tdata, // 16 8-bit samples
    input wire s00_axis_tlast,
    input wire s01_axis_tvalid,
    output reg s01_axis_tready,
    input wire [SDATA_WIDTH-1:0] s01_axis_tdata, // 16 8-bit samples
    input wire s01_axis_tlast,
    input wire s20_axis_tvalid,
    output reg s20_axis_tready,
    input wire [SDATA_WIDTH-1:0] s20_axis_tdata, // 16 8-bit samples
    input wire s20_axis_tlast,
    input wire s21_axis_tvalid,
    output reg s21_axis_tready,
    input wire [SDATA_WIDTH-1:0] s21_axis_tdata, // 16 8-bit samples
    input wire s21_axis_tlast,

    output reg [MDATA_WIDTH-1:0] m00_axis_s2mm_tdata,
    output reg [SDATA_WIDTH/SSAMPLE_WIDTH-1:0] m00_axis_s2mm_tkeep,
    output reg m00_axis_s2mm_tlast,
    input wire m00_axis_s2mm_tready,
    output reg m00_axis_s2mm_tvalid,
    output reg [MDATA_WIDTH-1:0] m01_axis_s2mm_tdata,
    output reg [SDATA_WIDTH/SSAMPLE_WIDTH-1:0] m01_axis_s2mm_tkeep,
    output reg m01_axis_s2mm_tlast,
    input wire m01_axis_s2mm_tready,
    output reg m01_axis_s2mm_tvalid,
    output reg [MDATA_WIDTH-1:0] m20_axis_s2mm_tdata,
    output reg [SDATA_WIDTH/SSAMPLE_WIDTH-1:0] m20_axis_s2mm_tkeep,
    output reg m20_axis_s2mm_tlast,
    input wire m20_axis_s2mm_tready,
    output reg m20_axis_s2mm_tvalid,
    output reg [MDATA_WIDTH-1:0] m21_axis_s2mm_tdata,
    output reg [SDATA_WIDTH/SSAMPLE_WIDTH-1:0] m21_axis_s2mm_tkeep,
    output reg m21_axis_s2mm_tlast,
    input wire m21_axis_s2mm_tready,
    output reg m21_axis_s2mm_tvalid
    );

    integer samples = SDATA_WIDTH/SSAMPLE_WIDTH;

    integer i;
    
  always @(posedge clock)
        begin
            if (resetn == 1'b0) //~resetn
                begin
                    // data out, valid, tread, and tlast should all be 0
                    m00_axis_s2mm_tdata = 0;
                    m00_axis_s2mm_tvalid = 0;
                    s00_axis_tready = 0;
                    m00_axis_s2mm_tlast = 0;

                    m01_axis_s2mm_tdata = 0;
                    m01_axis_s2mm_tvalid = 0;
                    s01_axis_tready = 0;
                    m01_axis_s2mm_tlast = 0;

                    m20_axis_s2mm_tdata = 0;
                    m20_axis_s2mm_tvalid = 0;
                    s20_axis_tready = 0;
                    m20_axis_s2mm_tlast = 0;

                    m21_axis_s2mm_tdata = 0;
                    m21_axis_s2mm_tvalid = 0;
                    s21_axis_tready = 0;
                    m21_axis_s2mm_tlast = 0;
                end
          else begin
            if (m00_axis_s2mm_tready && s00_axis_tvalid) begin
                // tkeep and tvalid are now high (tkeep = 16'hffff, tvalid = 1'b1)
                m00_axis_s2mm_tkeep <= 16'hffff;
                m00_axis_s2mm_tvalid <= 1'b1;
            end
            if((m00_axis_s2mm_tready && s00_axis_tvalid) || (m01_axis_s2mm_tready && s01_axis_tvalid) ||
               (m20_axis_s2mm_tready && s20_axis_tvalid) || (m20_axis_s2mm_tready && s00_axis_tvalid)) begin
                    // tkeep and tvalid are now high (tkeep = 16'hffff, tvalid = 1'b1)
                    m_axis_s2mm_tkeep <= 16'hffff;
                    m_axis_s2mm_tvalid <= 1'b1;

                    // this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
                    for(i=0; i<samples; i = i+1) begin
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
