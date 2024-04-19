/* 
 * AXI stream multiplier block taking 128-bit input data and 8-bit beamforming weight to apply to data
 */
module axis_multiplier
  #(
    parameter SDATA_WIDTH = 128,
    parameter SSAMPLE_WIDTH = 16,
    parameter WEIGHT_WIDTH = 8,
    parameter MSAMPLE_WIDTH = 16,   // SSAMPLE_WIDTH + WEIGHT_WIDTH
    parameter MDATA_WIDTH = 128,     // MSAMPLE_WIDTH * SAMPLES
    parameter BUFFER_WIDTH = SSAMPLE_WIDTH+WEIGHT_WIDTH,
    parameter SUM_BUFFER = MSAMPLE_WIDTH+1,
    parameter SAMPLES = SDATA_WIDTH/SSAMPLE_WIDTH
   ) 
    (
/*======================================BEGIN INPUTS=======================================*/
    input wire clock,
    input wire resetn,

    // this will be the multiplication factor for all 16 samples in its channel, should be <1
    input [WEIGHT_WIDTH-1:0] bWeight_real, // signed, 8-bit integer-scaled fixed point weight
    input [WEIGHT_WIDTH-1:0] bWeight_imag, // signed, 8-bit integer-scaled fixed point weight 
    
    /* all axis prefixed variables should be inferred per UG994 because of the 
     * use of the AXI standard naming convention */
    /*-------------------------Channel00 Input Real & Imag-------------------------*/
    input wire s_axis_real_tvalid,
    output reg s_axis_real_tready,
    input wire [SDATA_WIDTH-1:0] s_axis_real_tdata, // 8 16-bit samples
    input wire s_axis_real_tlast,

    input wire s_axis_imag_tvalid,
    output reg s_axis_imag_tready,
    input wire [SDATA_WIDTH-1:0] s_axis_imag_tdata, // 8 16-bit samples
    input wire s_axis_imag_tlast,
/*=======================================END INPUTS=======================================*/

/*=====================================BEGIN OUTPUTS======================================*/
    /*-------------------------Channel00 Output Real & Imag-------------------------*/
    output reg [MDATA_WIDTH-1:0] m_axis_real_s2mm_tdata,
    output reg [(SDATA_WIDTH/8)-1:0] m_axis_real_s2mm_tkeep,
    output reg m_axis_real_s2mm_tlast,
    input wire m_axis_real_s2mm_tready,
    output reg m_axis_real_s2mm_tvalid,

    output reg [MDATA_WIDTH-1:0] m_axis_imag_s2mm_tdata,
    output reg [(SDATA_WIDTH/8)-1:0] m_axis_imag_s2mm_tkeep,
    output reg m_axis_imag_s2mm_tlast,
    input wire m_axis_imag_s2mm_tready,
    output reg m_axis_imag_s2mm_tvalid
/*======================================END OUTPUTS=======================================*/
    );

    integer i;

    // we need bit overflow for the following 2's complement arithmetic:
    //       reg[SSAMPLE_WIDTH] * reg[WEIGHT_WIDTH],  reg2[SSAMPLE_WIDTH] * reg2[WEIGHT_WIDTH]
    //          we need dataBuffer of size SSAMPLE_WIDTH+WEIGHT_WIDTH (per sample)
    // reg [((SSAMPLE_WIDTH+WEIGHT_WIDTH)-1)*SAMPLES:0]dataBuffer; // with SSAMPLE_WIDTH=16 and WEIGHT_WIDTH=8, dataBuffer needs 24 bits * number of samples
    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s_tdata_real = 0; reg [(BUFFER_WIDTH*SAMPLES)-1:0]s_tdata_imag = 0;

    // this data buffer is for adding the real parts (or imaginary parts) for complex multiplication after they're weighted
    reg [((MSAMPLE_WIDTH+1)*SAMPLES)-1:0]addDataBuffer_re; reg [((MSAMPLE_WIDTH+1)*SAMPLES)-1:0]addDataBuffer_im;

    // pipelining
    reg [MDATA_WIDTH-1:0]m_tdata_real = 0;  reg [MDATA_WIDTH-1:0]m_tdata_imag = 0;
    reg [MDATA_WIDTH-1:0]m_tdata_reBuf = 0; reg [MDATA_WIDTH-1:0]m_tdata_imBuf = 0;
    reg [BUFFER_WIDTH-1:0] bw_re = 0;       reg [BUFFER_WIDTH-1:0] bw_im = 0;
    reg m00_valid = 0;

    // buffers for multiplication (for applying beamforming weights)
    //        reg [(BUFFER_WIDTH*SAMPLES)-1:0]s00_rr_weighted = reg [((16+8)*8)-1:0]s00_rr_weighted
    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s_rr_weighted = 0;  reg [(BUFFER_WIDTH*SAMPLES)-1:0]s_ii_weighted = 0;
    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s_ri_weighted = 0;  reg [(BUFFER_WIDTH*SAMPLES)-1:0]s_ir_weighted = 0;

    always @(posedge clock) begin
        //~resetn
        if (resetn == 1'b0) begin
            // data out, valid, tready, and tlast should all be 0
            m_axis_real_s2mm_tdata <= {MDATA_WIDTH{0}}; m_axis_imag_s2mm_tdata <= {MDATA_WIDTH{0}};
            m_axis_real_s2mm_tvalid <= 1'b0;            m_axis_imag_s2mm_tvalid <= 1'b0;
            s_axis_real_tready <= 1'b0;                 s_axis_imag_tready <= 1'b0;
            m_axis_real_s2mm_tlast <= 1'b0;             m_axis_imag_s2mm_tlast <= 1'b0;
        end else begin
            // always ready if not reset
            s_axis_real_tready <= 1'b1;       s_axis_imag_tready <= 1'b1; // Q: is there a reason we're not setting this to the input tready?

            m_tlast_re[0] <= s_axis_real_tlast;
            m_tlast_im[0] <= s_axis_imag_tlast;
            
            // setting beamforming weight registers for pipelining and sign-extending each for later multiplication
            bw_re <= {{SSAMPLE_WIDTH{bWeight_real[WEIGHT_WIDTH]}}, bWeight_real};
            bw_im <= {{SSAMPLE_WIDTH{bWeight_imag[WEIGHT_WIDTH]}}, bWeight_imag};

            /*------------------------CHANNEL READY/VALID------------------------*/
            if (m_axis_real_s2mm_tready && s_axis_real_tvalid && m_axis_imag_s2mm_tready && s_axis_imag_tvalid) begin
                // tkeep and tvalid are now high (tkeep = 16'hffff, tvalid = 1'b1)
                m_axis_real_s2mm_tkeep <= {SAMPLES{1}};   m_axis_imag_s2mm_tkeep <= {SAMPLES{1}};

                // this for loop multiplies every eight bits by bWeights (it'll loop 8 times- 1 time per sample in tdata)
                for(i=0; i<SAMPLES; i = i+1) begin
                    /* multiply by appropriate weight, accounting for complex/real parts of weight */
                    // sign extending real and imag parts of slave data for multiplication
                    // also adding 8 LSBS = 0 so when we multiply by the fixed-point weights all the bits line up
                    s_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= {{WEIGHT_WIDTH{s_axis_real_tdata[(i+1)*SSAMPLE_WIDTH-1]}}, s_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]};
                    s_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= {{WEIGHT_WIDTH{s_axis_imag_tdata[(i+1)*SSAMPLE_WIDTH-1]}}, s_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]};

                    s_rr_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH]*bw_re;
                    s_ii_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH]*bw_im;

                    // truncating s00_rr_weighted and s00_ii_weighted by taking the MSBs of size MSAMPLE_WIDTH (sign extension earlier
                    // enables us to do this because their sign is preserved)
                    //      KATIE pls double check that verilog will truncate to the LSBs in this assignment (and NOT the MSBs)
                    addDataBuffer_re[i*(MSAMPLE_WIDTH+1) +: (MSAMPLE_WIDTH+1)] <= s_rr_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH]
                                                                      - s_ii_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH];
                    // truncating addDataBuffer by taking the LSBs of size MSAMPLE_WIDTH (twos complement addition preserves sign)
                    m_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= addDataBuffer_re[i*(MSAMPLE_WIDTH+1)+1 +: MSAMPLE_WIDTH];

                    m_tlast_re[i+1] <= m_tlast_re[i];

                    s_ir_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH]*bw_im;
                    s_ri_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH]*bw_re;

                    addDataBuffer_im[i*(MSAMPLE_WIDTH+1) +: (MSAMPLE_WIDTH+1)] <= s_ir_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH]
                                                                      + s_ri_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH];
                    // truncating addDataBuffer by taking the LSBs of size MSAMPLE_WIDTH (twos complement addition preserves sign)
                    m_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= addDataBuffer_im[i*(MSAMPLE_WIDTH+1) +: MSAMPLE_WIDTH];

                    m_tlast_im[i+1] <= m_tlast_im[i];
                end

                m_axis_real_s2mm_tvalid <= 1'b1;      m_axis_imag_s2mm_tvalid <= 1'b1;
                m_valid <= m_axis_real_s2mm_tvalid && m_axis_imag_s2mm_tvalid;

                m_axis_real_s2mm_tlast <= m_tlast_re[SAMPLES];    m_axis_imag_s2mm_tlast <= m_tlast_im[SAMPLES];
            end
            /*----------------------CHANNEL NOT READY/VALID----------------------*/
            else begin 
                // invalid data, so output data is set to static value of 0
                m_axis_real_s2mm_tdata <= {MDATA_WIDTH{0}};
                m_axis_imag_s2mm_tdata <= {MDATA_WIDTH{0}};

                // output valid and output tkeep should be low
                m_axis_real_s2mm_tvalid <= 1'b0; m_axis_imag_s2mm_tvalid <= 1'b0;
                m_axis_real_s2mm_tkeep <= 1'b0;  m_axis_imag_s2mm_tkeep <= 1'b0;
            end
        end
    end
endmodule