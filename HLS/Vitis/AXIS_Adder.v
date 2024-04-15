/* 
 * AXI stream multiplier block taking 128-bit input data and 8-bit beamforming weight to apply to data
*/
module axis_adder
  #(
    parameter SDATA_WIDTH = 128,
    parameter SSAMPLE_WIDTH = 16,
    parameter WEIGHT_WIDTH = 8,
    parameter MSAMPLE_WIDTH = 16,   // SSAMPLE_WIDTH + WEIGHT_WIDTH
    parameter MDATA_WIDTH = 128,     // MSAMPLE_WIDTH * SAMPLES
    parameter BUFFER_WIDTH = SSAMPLE_WIDTH+WEIGHT_WIDTH,
    parameter BUFFER_WIDTH_SUM = SSAMPLE_WIDTH+2,
    parameter SAMPLES = SDATA_WIDTH/SSAMPLE_WIDTH
   ) 
    (
/*======================================BEGIN INPUTS=======================================*/
    input wire clock,
    input wire resetn,

    // this will be the multiplication factor for all 16 samples in its channel, should be <1
    input signed [WEIGHT_WIDTH-1:0] bWeight00_real, // unsigned, 8-bit integer
    input signed [WEIGHT_WIDTH-1:0] bWeight00_imag, // unsigned, 8-bit integer
    input signed [WEIGHT_WIDTH-1:0] bWeight01_real, // unsigned, 8-bit integer
    input signed [WEIGHT_WIDTH-1:0] bWeight01_imag, // unsigned, 8-bit integer
    input signed [WEIGHT_WIDTH-1:0] bWeight20_real, // unsigned, 8-bit integer
    input signed [WEIGHT_WIDTH-1:0] bWeight20_imag, // unsigned, 8-bit integer
    input signed [WEIGHT_WIDTH-1:0] bWeight21_real, // unsigned, 8-bit integer
    input signed [WEIGHT_WIDTH-1:0] bWeight21_imag, // unsigned, 8-bit integer
    
    /* all axis prefixed variables should be inferred per UG994 because of the 
     * use of the AXI standard naming convention */
    /*-------------------------Channel00 Input Real & Imag-------------------------*/
    input wire s00_axis_real_tvalid,
    output reg s00_axis_real_tready,
    input wire [SDATA_WIDTH-1:0] s00_axis_real_tdata, // 8 16-bit samples
    input wire s00_axis_real_tlast,

    input wire s00_axis_imag_tvalid,
    output reg s00_axis_imag_tready,
    input wire [SDATA_WIDTH-1:0] s00_axis_imag_tdata, // 8 16-bit samples
    input wire s00_axis_imag_tlast,
    /*-------------------------Channel01 Input Real & Imag-------------------------*/
    input wire s01_axis_real_tvalid,
    output reg s01_axis_real_tready,
    input wire [SDATA_WIDTH-1:0] s01_axis_real_tdata, // 8 16-bit samples
    input wire s01_axis_real_tlast,

    input wire s01_axis_imag_tvalid,
    output reg s01_axis_imag_tready,
    input wire [SDATA_WIDTH-1:0] s01_axis_imag_tdata, // 16 8-bit samples
    input wire s01_axis_imag_tlast,
    /*-------------------------Channel20 Input Real & Imag-------------------------*/
    input wire s20_axis_real_tvalid,
    output reg s20_axis_real_tready,
    input wire [SDATA_WIDTH-1:0] s20_axis_real_tdata, // 16 8-bit samples
    input wire s20_axis_real_tlast,

    input wire s20_axis_imag_tvalid,
    output reg s20_axis_imag_tready,
    input wire [SDATA_WIDTH-1:0] s20_axis_imag_tdata, // 16 8-bit samples
    input wire s20_axis_imag_tlast,
    /*-------------------------Channel21 Input Real & Imag-------------------------*/
    input wire s21_axis_real_tvalid,
    output reg s21_axis_real_tready,
    input wire [SDATA_WIDTH-1:0] s21_axis_real_tdata, // 16 8-bit samples
    input wire s21_axis_real_tlast,

    input wire s21_axis_imag_tvalid,
    output reg s21_axis_imag_tready,
    input wire [SDATA_WIDTH-1:0] s21_axis_imag_tdata, // 16 8-bit samples
    input wire s21_axis_imag_tlast,
    /*-------------------------Channel21 Input Real & Imag-------------------------*/
/*=======================================END INPUTS=======================================*/

/*=====================================BEGIN OUTPUTS======================================*/
    /*-------------------------Channel00 Output Real & Imag-------------------------*/
    output reg [MDATA_WIDTH-1:0] m00_axis_real_s2mm_tdata,
    output reg [(SDATA_WIDTH/8)-1:0] m00_axis_real_s2mm_tkeep,
    output reg m00_axis_real_s2mm_tlast,
    input wire m00_axis_real_s2mm_tready,
    output reg m00_axis_real_s2mm_tvalid,

    output reg [MDATA_WIDTH-1:0] m00_axis_imag_s2mm_tdata,
    output reg [(SDATA_WIDTH/8)-1:0] m00_axis_imag_s2mm_tkeep,
    output reg m00_axis_imag_s2mm_tlast,
    input wire m00_axis_imag_s2mm_tready,
    output reg m00_axis_imag_s2mm_tvalid,
    /*-------------------------Channel01 Output Real & Imag-------------------------*/
    output reg [MDATA_WIDTH-1:0] m01_axis_real_s2mm_tdata,
    output reg [(SDATA_WIDTH/8)-1:0] m01_axis_real_s2mm_tkeep,
    output reg m01_axis_real_s2mm_tlast,
    input wire m01_axis_real_s2mm_tready,
    output reg m01_axis_real_s2mm_tvalid,

    output reg [MDATA_WIDTH-1:0] m01_axis_imag_s2mm_tdata,
    output reg [(SDATA_WIDTH/8)-1:0] m01_axis_imag_s2mm_tkeep,
    output reg m01_axis_imag_s2mm_tlast,
    input wire m01_axis_imag_s2mm_tready,
    output reg m01_axis_imag_s2mm_tvalid,
    /*-------------------------Channel20 Output Real & Imag-------------------------*/
    output reg [MDATA_WIDTH-1:0] m20_axis_real_s2mm_tdata,
    output reg [(SDATA_WIDTH/8)-1:0] m20_axis_real_s2mm_tkeep,
    output reg m20_axis_real_s2mm_tlast,
    input wire m20_axis_real_s2mm_tready,
    output reg m20_axis_real_s2mm_tvalid,

    output reg [MDATA_WIDTH-1:0] m20_axis_imag_s2mm_tdata,
    output reg [(SDATA_WIDTH/8)-1:0] m20_axis_imag_s2mm_tkeep,
    output reg m20_axis_imag_s2mm_tlast,
    input wire m20_axis_imag_s2mm_tready,
    output reg m20_axis_imag_s2mm_tvalid,
    /*-------------------------Channel21 Output Real & Imag-------------------------*/
    output reg [MDATA_WIDTH-1:0] m21_axis_real_s2mm_tdata,
    output reg [(SDATA_WIDTH/8)-1:0] m21_axis_real_s2mm_tkeep,
    output reg m21_axis_real_s2mm_tlast,
    input wire m21_axis_real_s2mm_tready,
    output reg m21_axis_real_s2mm_tvalid,

    output reg [MDATA_WIDTH-1:0] m21_axis_imag_s2mm_tdata,
    output reg [(SDATA_WIDTH/8)-1:0] m21_axis_imag_s2mm_tkeep,
    output reg m21_axis_imag_s2mm_tlast,
    input wire m21_axis_imag_s2mm_tready,
    output reg m21_axis_imag_s2mm_tvalid
/*======================================END OUTPUTS=======================================*/
    );

    integer i;

    // we need bit overflow for the following 2's complement arithmetic:
    //       reg[SSAMPLE_WIDTH] * reg[WEIGHT_WIDTH] + reg2[SSAMPLE_WIDTH] * reg2[WEIGHT_WIDTH] => 
    //          we need dataBuffer of size SSAMPLE_WIDTH+WEIGHT_WIDTH+1 (per sample)
    // reg [((SSAMPLE_WIDTH+WEIGHT_WIDTH+1)-1)*SAMPLES:0]dataBuffer; // with SSAMPLE_WIDTH=16 and WEIGHT_WIDTH=8, dataBuffer needs 25 bits * number of samples

    // reg [((SSAMPLE_WIDTH+3)-1)*SAMPLES:0]dataBuffer_Sum;
    reg [BUFFER_WIDTH_SUM*SAMPLES:0]dataBuffer_SumRe = 0;
    reg [BUFFER_WIDTH_SUM*SAMPLES:0]dataBuffer_SumIm = 0;

    // this data buffer is for adding the real parts (or imaginary parts) for complex multiplication after they're weighted
    reg [((MSAMPLE_WIDTH+1)*SAMPLES)-1:0]addDataBuffer00_re; reg [((MSAMPLE_WIDTH+1)*SAMPLES)-1:0]addDataBuffer00_im;
    reg [((MSAMPLE_WIDTH+1)*SAMPLES)-1:0]addDataBuffer01_re; reg [((MSAMPLE_WIDTH+1)*SAMPLES)-1:0]addDataBuffer01_im;
    reg [((MSAMPLE_WIDTH+1)*SAMPLES)-1:0]addDataBuffer20_re; reg [((MSAMPLE_WIDTH+1)*SAMPLES)-1:0]addDataBuffer20_im;
    reg [((MSAMPLE_WIDTH+1)*SAMPLES)-1:0]addDataBuffer21_re; reg [((MSAMPLE_WIDTH+1)*SAMPLES)-1:0]addDataBuffer21_im;

    // pipelining for channel00 because it's the channel we're writing the summed & weighted data to
    reg [MDATA_WIDTH-1:0]m00_tdata_real = 0; reg [MDATA_WIDTH-1:0]m00_tdata_imag = 0;

    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s00_tdata_real = 0; reg [(BUFFER_WIDTH*SAMPLES)-1:0]s00_tdata_imag = 0;
    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s01_tdata_real = 0; reg [(BUFFER_WIDTH*SAMPLES)-1:0]s01_tdata_imag = 0;
    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s20_tdata_real = 0; reg [(BUFFER_WIDTH*SAMPLES)-1:0]s20_tdata_imag = 0;
    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s21_tdata_real = 0; reg [(BUFFER_WIDTH*SAMPLES)-1:0]s21_tdata_imag = 0;

    // buffers for multiplication (for applying beamforming weights)
    //        reg [(BUFFER_WIDTH*SAMPLES)-1:0]s00_rr_weighted = reg [((16+8)*8)-1:0]s00_rr_weighted
    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s00_rr_weighted = 0;  reg [(BUFFER_WIDTH*SAMPLES)-1:0]s00_ii_weighted = 0;
    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s00_ri_weighted = 0;  reg [(BUFFER_WIDTH*SAMPLES)-1:0]s00_ir_weighted = 0;
    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s01_rr_weighted = 0;  reg [(BUFFER_WIDTH*SAMPLES)-1:0]s01_ii_weighted = 0;
    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s01_ri_weighted = 0;  reg [(BUFFER_WIDTH*SAMPLES)-1:0]s01_ir_weighted = 0;
    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s20_rr_weighted = 0;  reg [(BUFFER_WIDTH*SAMPLES)-1:0]s20_ii_weighted = 0;
    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s20_ri_weighted = 0;  reg [(BUFFER_WIDTH*SAMPLES)-1:0]s20_ir_weighted = 0;
    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s21_rr_weighted = 0;  reg [(BUFFER_WIDTH*SAMPLES)-1:0]s21_ii_weighted = 0;
    reg [(BUFFER_WIDTH*SAMPLES)-1:0]s21_ri_weighted = 0;  reg [(BUFFER_WIDTH*SAMPLES)-1:0]s21_ir_weighted = 0;


    // pipelining for beamforming weights
    reg [BUFFER_WIDTH-1:0] bw00_re_ = 0; reg [BUFFER_WIDTH-1:0] bw00_im_ = 0;
    reg [BUFFER_WIDTH-1:0] bw01_re_ = 0; reg [BUFFER_WIDTH-1:0] bw01_im_ = 0;
    reg [BUFFER_WIDTH-1:0] bw20_re_ = 0; reg [BUFFER_WIDTH-1:0] bw20_im_ = 0;
    reg [BUFFER_WIDTH-1:0] bw21_re_ = 0; reg [BUFFER_WIDTH-1:0] bw21_im_ = 0;

    reg [BUFFER_WIDTH-1:0] bw00_re = 0;  reg [BUFFER_WIDTH-1:0] bw00_im = 0;
    reg [BUFFER_WIDTH-1:0] bw01_re = 0;  reg [BUFFER_WIDTH-1:0] bw01_im = 0;
    reg [BUFFER_WIDTH-1:0] bw20_re = 0;  reg [BUFFER_WIDTH-1:0] bw20_im = 0;
    reg [BUFFER_WIDTH-1:0] bw21_re = 0;  reg [BUFFER_WIDTH-1:0] bw21_im = 0;

    reg [SSAMPLE_WIDTH-1:0] spongeyBob = 0;
    reg signed [BUFFER_WIDTH-1:0] garyTheSnail = 0;
    
    always @(posedge clock) begin
        //~resetn
        if (resetn == 1'b0) begin
            // data out, valid, tready, and tlast should all be 0
            m00_axis_real_s2mm_tdata = 128'b0;   m00_axis_imag_s2mm_tdata = 128'b0;
            m00_axis_real_s2mm_tvalid = 1'b0;  m00_axis_imag_s2mm_tvalid = 1'b0;
            s00_axis_real_tready = 1'b0;       s00_axis_imag_tready = 1'b0;
            m00_axis_real_s2mm_tlast = 1'b0;   m00_axis_imag_s2mm_tlast = 1'b0;

            m01_axis_real_s2mm_tdata = 128'b0;   m01_axis_imag_s2mm_tdata = 128'b0;
            m01_axis_real_s2mm_tvalid = 1'b0;  m01_axis_imag_s2mm_tvalid = 1'b0;
            s01_axis_real_tready = 1'b0;       s01_axis_imag_tready = 1'b0;
            m01_axis_real_s2mm_tlast = 1'b0;   m01_axis_imag_s2mm_tlast = 1'b0;

            m20_axis_real_s2mm_tdata = 128'b0;   m20_axis_imag_s2mm_tdata = 128'b0;
            m20_axis_real_s2mm_tvalid = 1'b0;  m20_axis_imag_s2mm_tvalid = 1'b0;
            s20_axis_real_tready = 1'b0;       s20_axis_imag_tready = 1'b0;
            m20_axis_real_s2mm_tlast = 1'b0;   m20_axis_imag_s2mm_tlast = 1'b0;

            m21_axis_real_s2mm_tdata = 128'b0;   m21_axis_imag_s2mm_tdata = 128'b0;
            m21_axis_real_s2mm_tvalid = 1'b0;  m21_axis_imag_s2mm_tvalid = 1'b0;
            s21_axis_real_tready = 1'b0;       s21_axis_imag_tready = 1'b0;
            m21_axis_real_s2mm_tlast = 1'b0;   m21_axis_imag_s2mm_tlast = 1'b0;
        end
        else begin
            // always ready if not reset!
            s00_axis_real_tready = 1'b1;       s00_axis_imag_tready = 1'b1;
            s01_axis_real_tready = 1'b1;       s01_axis_imag_tready = 1'b1;
            s20_axis_real_tready = 1'b1;       s20_axis_imag_tready = 1'b1;
            s21_axis_real_tready = 1'b1;       s21_axis_imag_tready = 1'b1;

            m00_axis_real_s2mm_tlast <= s00_axis_real_tlast;    m00_axis_imag_s2mm_tlast <= s00_axis_imag_tlast;
            m01_axis_real_s2mm_tlast <= s01_axis_real_tlast;    m01_axis_imag_s2mm_tlast <= s01_axis_imag_tlast;
            m20_axis_real_s2mm_tlast <= s20_axis_real_tlast;    m20_axis_imag_s2mm_tlast <= s20_axis_imag_tlast;
            m21_axis_real_s2mm_tlast <= s21_axis_real_tlast;    m21_axis_imag_s2mm_tlast <= s21_axis_imag_tlast;

            // setting beamforming weight registers for pipelining and sign-extending each for later multiplication
            bw00_re <= bWeight00_real <<< SSAMPLE_WIDTH;
            bw00_im <= bWeight00_imag <<< SSAMPLE_WIDTH;
            bw01_re <= bWeight01_real <<< SSAMPLE_WIDTH;
            bw01_im <= bWeight01_imag <<< SSAMPLE_WIDTH;
            bw20_re <= bWeight20_real <<< SSAMPLE_WIDTH;
            bw20_im <= bWeight20_imag <<< SSAMPLE_WIDTH;
            bw21_re <= bWeight21_real <<< SSAMPLE_WIDTH;
            bw21_im <= bWeight21_imag <<< SSAMPLE_WIDTH;

            // <3 (this is just a bit mask for "sign extension" of slave tdata buffers)
            garyTheSnail <= ~spongeyBob <<< WEIGHT_WIDTH;

            /*------------------------CHANNEL 00 READY/VALID------------------------*/
            if (m00_axis_real_s2mm_tready && s00_axis_real_tvalid && m00_axis_imag_s2mm_tready && s00_axis_imag_tvalid) begin
                // tkeep and tvalid are now high (tkeep = 16'hffff, tvalid = 1'b1)
                m00_axis_real_s2mm_tkeep <= 16'hffff;   m00_axis_imag_s2mm_tkeep <= 16'hffff;
                m00_axis_real_s2mm_tvalid <= 1'b1;      m00_axis_imag_s2mm_tvalid <= 1'b1;

                // this for loop multiplies every eight bits by bWeights (it'll loop 8 times- 1 time per sample in tdata)
                for(i=0; i<SAMPLES; i = i+1) begin
                    // this can be a non-blocking assignment because there is a blocking assignment in the incrementing of i
                    /* multiply by appropriate weight, accounting for complex/real parts of weight */
                    // sign extending real and imag parts of slave data for multiplication
                    if (s00_axis_real_tdata[(i+1)*SSAMPLE_WIDTH-1]) begin
                        s00_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s00_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH] | garyTheSnail;
                    end else begin
                        s00_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s00_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
                    end
                    if (s00_axis_imag_tdata[(i+1)*SSAMPLE_WIDTH-1]) begin
                        s00_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s00_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH] | garyTheSnail;
                    end else begin
                        s00_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s00_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
                    end

                    s00_rr_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s00_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw00_re;
                    s00_ii_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s00_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw00_im;

                    // truncating s00_rr_weighted and s00_ii_weighted by taking the MSBs of size MSAMPLE_WIDTH (sign extension earlier
                    // enables us to do this because their sign is preserved)
                    //      KATIE pls double check that verilog will truncate to the LSBs in this assignment (and NOT the MSBs)
                    addDataBuffer00_re[i*(MSAMPLE_WIDTH+1) +: (MSAMPLE_WIDTH+1)] <= s00_rr_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH]
                                                                      + s00_ii_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH];
                    // truncating addDataBuffer by taking the LSBs of size MSAMPLE_WIDTH (twos complement addition preserves sign)
                    m00_tdata_real[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= addDataBuffer00_re[i*(MSAMPLE_WIDTH+1)+1 +: MSAMPLE_WIDTH];

                    s00_ir_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s00_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw00_im;
                    s00_ri_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s00_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw00_re;

                    addDataBuffer00_im[i*(MSAMPLE_WIDTH+1) +: (MSAMPLE_WIDTH+1)] <= s00_ir_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH]
                                                                      + s00_ri_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH];
                    // truncating addDataBuffer by taking the LSBs of size MSAMPLE_WIDTH (twos complement addition preserves sign)
                    m00_tdata_imag[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= addDataBuffer00_im[i*(MSAMPLE_WIDTH+1) +: MSAMPLE_WIDTH];
                end
            end
            /*----------------------CHANNEL 00 NOT READY/VALID----------------------*/
            else begin 
                // invalid data, so output data is set to static value of 0
                m00_axis_real_s2mm_tdata <= 128'b0;
                m00_axis_imag_s2mm_tdata <= 128'b0;

                // output valid and output tkeep should be low
                m00_axis_real_s2mm_tvalid <= 1'b0; m00_axis_imag_s2mm_tvalid <= 1'b0;
                m00_axis_real_s2mm_tkeep <= 1'b0;  m00_axis_imag_s2mm_tkeep <= 1'b0;
            end
            /*------------------------CHANNEL 01 READY/VALID------------------------*/
            if (m01_axis_real_s2mm_tready && s01_axis_real_tvalid && m01_axis_imag_s2mm_tready && s01_axis_imag_tvalid) begin
                // tkeep and tvalid are now high (tkeep = 16'hffff, tvalid = 1'b1)
                m01_axis_real_s2mm_tkeep <= 16'hffff;   m01_axis_imag_s2mm_tkeep <= 16'hffff;
                m01_axis_real_s2mm_tvalid <= 1'b1;      m01_axis_imag_s2mm_tvalid <= 1'b1;

                // this for loop multiplies every eight bits by bWeights (it'll loop 8 times- 1 time per sample in tdata)
                for(i=0; i<SAMPLES; i = i+1) begin
                    // this can be a non-blocking assignment because there is a blocking assignment in the incrementing of i
                    /* multiply by appropriate weight, accounting for complex/real parts of weight */
                    // sign extending real and imag parts of slave data for multiplication
                    if (s01_axis_real_tdata[(i+1)*SSAMPLE_WIDTH-1]) begin
                        s01_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s01_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH] | garyTheSnail;
                    end else begin
                        s01_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s01_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
                    end
                    if (s01_axis_imag_tdata[(i+1)*SSAMPLE_WIDTH-1]) begin
                        s01_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s01_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH] | garyTheSnail;
                    end else begin
                        s01_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s01_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
                    end

                    s01_rr_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s01_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw01_re;
                    s01_ii_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s01_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw01_im;

                    // truncating s01_rr_weighted and s01_ii_weighted by taking the MSBs of size MSAMPLE_WIDTH (sign extension earlier
                    // enables us to do this because their sign is preserved)
                    addDataBuffer01_re[i*(MSAMPLE_WIDTH+1) +: (MSAMPLE_WIDTH+1)] <= s01_rr_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH]
                                                                      + s01_ii_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH];
                    // truncating addDataBuffer by taking the LSBs of size MSAMPLE_WIDTH (twos complement addition preserves sign)
                    m01_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= addDataBuffer01_re[i*(MSAMPLE_WIDTH+1)+1 +: MSAMPLE_WIDTH];

                    s01_ir_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s01_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw01_im;
                    s01_ri_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s01_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw01_re;

                    addDataBuffer01_im[i*(MSAMPLE_WIDTH+1) +: (MSAMPLE_WIDTH+1)] <= s01_ir_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH]
                                                                      + s01_ri_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH];
                    // truncating addDataBuffer by taking the LSBs of size MSAMPLE_WIDTH (twos complement addition preserves sign)
                    m01_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= addDataBuffer01_im[i*(MSAMPLE_WIDTH+1) +: MSAMPLE_WIDTH];
                end
            end
            /*----------------------CHANNEL 01 NOT READY/VALID----------------------*/
            else begin 
                // invalid data, so output data is set to static value of 0
                m01_axis_real_s2mm_tdata <= 128'b0;
                m01_axis_imag_s2mm_tdata <= 128'b0;

                // output valid and output tkeep should be low
                m01_axis_real_s2mm_tvalid <= 1'b0; m01_axis_imag_s2mm_tvalid <= 1'b0;
                m01_axis_real_s2mm_tkeep <= 1'b0;  m01_axis_imag_s2mm_tkeep <= 1'b0;
            end
            /*------------------------CHANNEL 20 READY/VALID------------------------*/
            if (m20_axis_real_s2mm_tready && s20_axis_real_tvalid && m20_axis_imag_s2mm_tready && s20_axis_imag_tvalid) begin
                // tkeep and tvalid are now high (tkeep = 16'hffff, tvalid = 1'b1)
                m20_axis_real_s2mm_tkeep <= 16'hffff;   m20_axis_imag_s2mm_tkeep <= 16'hffff;
                m20_axis_real_s2mm_tvalid <= 1'b1;      m20_axis_imag_s2mm_tvalid <= 1'b1;

                // this for loop multiplies every eight bits by bWeights (it'll loop 8 times- 1 time per sample in tdata)
                for(i=0; i<SAMPLES; i = i+1) begin
                    // this can be a non-blocking assignment because there is a blocking assignment in the incrementing of i
                    /* multiply by appropriate weight, accounting for complex/real parts of weight */
                    // sign extending real and imag parts of slave data for multiplication
                    if (s20_axis_real_tdata[(i+1)*SSAMPLE_WIDTH-1]) begin
                        s20_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s20_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH] | garyTheSnail;
                    end else begin
                        s20_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s20_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
                    end
                    if (s20_axis_imag_tdata[(i+1)*SSAMPLE_WIDTH-1]) begin
                        s20_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s20_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH] | garyTheSnail;
                    end else begin
                        s20_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s20_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
                    end

                    s20_rr_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s20_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw20_re;
                    s20_ii_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s20_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw20_im;

                    // truncating s20_rr_weighted and s20_ii_weighted by taking the MSBs of size MSAMPLE_WIDTH (sign extension earlier
                    // enables us to do this because their sign is preserved)
                    addDataBuffer20_re[i*(MSAMPLE_WIDTH+1) +: (MSAMPLE_WIDTH+1)] <= s20_rr_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH]
                                                                      + s20_ii_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH];
                    // truncating addDataBuffer by taking the LSBs of size MSAMPLE_WIDTH (twos complement addition preserves sign)
                    m20_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= addDataBuffer20_re[i*(MSAMPLE_WIDTH+1)+1 +: MSAMPLE_WIDTH];

                    s20_ir_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s20_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw20_im;
                    s20_ri_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s20_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw20_re;

                    addDataBuffer20_im[i*(MSAMPLE_WIDTH+1) +: (MSAMPLE_WIDTH+1)] <= s20_ir_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH]
                                                                      + s20_ri_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH];
                    // truncating addDataBuffer by taking the LSBs of size MSAMPLE_WIDTH (twos complement addition preserves sign)
                    m20_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= addDataBuffer20_im[i*(MSAMPLE_WIDTH+1) +: MSAMPLE_WIDTH];
                end
            end
            /*----------------------CHANNEL 20 NOT READY/VALID----------------------*/
            else begin 
                // invalid data, so output data is set to static value of 0
                m20_axis_real_s2mm_tdata <= 128'b0;
                m20_axis_imag_s2mm_tdata <= 128'b0;

                // output valid and output tkeep should be low
                m20_axis_real_s2mm_tvalid <= 1'b0; m20_axis_imag_s2mm_tvalid <= 1'b0;
                m20_axis_real_s2mm_tkeep <= 1'b0;  m20_axis_imag_s2mm_tkeep <= 1'b0;
            end
            /*------------------------CHANNEL 21 READY/VALID------------------------*/
            if (m21_axis_real_s2mm_tready && s21_axis_real_tvalid && m21_axis_imag_s2mm_tready && s21_axis_imag_tvalid) begin
                // tkeep and tvalid are now high (tkeep = 16'hffff, tvalid = 1'b1)
                m21_axis_real_s2mm_tkeep <= 16'hffff;   m21_axis_imag_s2mm_tkeep <= 16'hffff;
                m21_axis_real_s2mm_tvalid <= 1'b1;      m21_axis_imag_s2mm_tvalid <= 1'b1;

                // this for loop multiplies every eight bits by bWeights (it'll loop 8 times- 1 time per sample in tdata)
                for(i=0; i<SAMPLES; i = i+1) begin
                    // this can be a non-blocking assignment because there is a blocking assignment in the incrementing of i
                    /* multiply by appropriate weight, accounting for complex/real parts of weight */
                    // sign extending real and imag parts of slave data for multiplication
                    if (s21_axis_real_tdata[(i+1)*SSAMPLE_WIDTH-1]) begin
                        s21_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s21_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH] | garyTheSnail;
                    end else begin
                        s21_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s21_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
                    end
                    if (s21_axis_imag_tdata[(i+1)*SSAMPLE_WIDTH-1]) begin
                        s21_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s21_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH] | garyTheSnail;
                    end else begin
                        s21_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s21_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
                    end

                    s21_rr_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s21_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw21_re;
                    s21_ii_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s21_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw21_im;

                    // truncating s21_rr_weighted and s21_ii_weighted by taking the MSBs of size MSAMPLE_WIDTH (sign extension earlier
                    // enables us to do this because their sign is preserved)
                    addDataBuffer21_re[i*(MSAMPLE_WIDTH+1) +: (MSAMPLE_WIDTH+1)] <= s21_rr_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH]
                                                                      + s21_ii_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH];
                    // truncating addDataBuffer by taking the LSBs of size MSAMPLE_WIDTH (twos complement addition preserves sign)
                    m21_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= addDataBuffer21_re[i*(MSAMPLE_WIDTH+1)+1 +: MSAMPLE_WIDTH];

                    s21_ir_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s21_tdata_real[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw21_im;
                    s21_ri_weighted[i*BUFFER_WIDTH +: BUFFER_WIDTH] <= s21_tdata_imag[i*BUFFER_WIDTH +: BUFFER_WIDTH]/bw21_re;

                    addDataBuffer21_im[i*(MSAMPLE_WIDTH+1) +: (MSAMPLE_WIDTH+1)] <= s21_ir_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH]
                                                                      + s21_ri_weighted[(i*BUFFER_WIDTH)+WEIGHT_WIDTH +: MSAMPLE_WIDTH];
                    // truncating addDataBuffer by taking the LSBs of size MSAMPLE_WIDTH (twos complement addition preserves sign)
                    m21_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= addDataBuffer21_im[i*(MSAMPLE_WIDTH+1) +: MSAMPLE_WIDTH];
                end
            end
            /*----------------------CHANNEL 21 NOT READY/VALID----------------------*/
            else begin 
                // invalid data, so output data is set to static value of 0
                m21_axis_real_s2mm_tdata <= 128'b0;
                m21_axis_imag_s2mm_tdata <= 128'b0;

                // output valid and output tkeep should be low
                m21_axis_real_s2mm_tvalid <= 1'b0; m21_axis_imag_s2mm_tvalid <= 1'b0;
                m21_axis_real_s2mm_tkeep <= 1'b0;  m21_axis_imag_s2mm_tkeep <= 1'b0;
            end

            // If any of the channels have valid data, sum all four
            if((s00_axis_real_tready && s00_axis_imag_tready) || (s01_axis_real_tready && s01_axis_imag_tready)  ||
               (s20_axis_real_tready && s20_axis_imag_tready) || (s21_axis_real_tready && s21_axis_imag_tready)) begin
                // this for loop multiplies every eight bits by bWeights (it'll loop 8 times- 1 time per sample in tdata)
                for(i=0; i<SAMPLES; i = i+1) begin
                    // this can be a non-blocking assignment because there is a blocking assignment in the incrementing of i
                    dataBuffer_SumRe[i*BUFFER_WIDTH_SUM +: BUFFER_WIDTH_SUM] <= m00_tdata_real[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] + m01_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH]
                        + m20_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] + m21_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH];
                    
                    m00_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer_SumRe[i*BUFFER_WIDTH_SUM +: MSAMPLE_WIDTH];

                    dataBuffer_SumIm[i*BUFFER_WIDTH_SUM +: BUFFER_WIDTH_SUM] <= m00_tdata_imag[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] + m01_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH]
                        + m20_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] + m21_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH];
                    
                    m00_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer_SumIm[i*BUFFER_WIDTH_SUM +: MSAMPLE_WIDTH];
                end
            end
         end
    end
endmodule
