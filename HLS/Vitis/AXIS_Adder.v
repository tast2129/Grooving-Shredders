/* 
 * AXI stream multiplier block taking 128-bit input data and 8-bit beamforming weight to apply to data
*/
module axis_adder
  #(
    parameter SDATA_WIDTH = 128,
    parameter SSAMPLE_WIDTH = 16,
    parameter WEIGHT_WIDTH = 8,
    parameter MSAMPLE_WIDTH = 16,   // SSAMPLE_WIDTH + WEIGHT_WIDTH
    parameter MDATA_WIDTH = 128     // MSAMPLE_WIDTH * SAMPLES
   ) 
    (
/*======================================BEGIN INPUTS=======================================*/
    input wire clock,
    input wire resetn,

    // this will be the multiplication factor for all 16 samples in its channel, should be <1
    input [WEIGHT_WIDTH-1:0] bWeight00_real,
    input [WEIGHT_WIDTH-1:0] bWeight00_imag,
    input [WEIGHT_WIDTH-1:0] bWeight01_real,
    input [WEIGHT_WIDTH-1:0] bWeight01_imag,
    input [WEIGHT_WIDTH-1:0] bWeight20_real,
    input [WEIGHT_WIDTH-1:0] bWeight20_imag,
    input [WEIGHT_WIDTH-1:0] bWeight21_real,
    input [WEIGHT_WIDTH-1:0] bWeight21_imag,
    
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
    output reg [SDATA_WIDTH/SSAMPLE_WIDTH-1:0] m00_axis_real_s2mm_tkeep,
    output reg m00_axis_real_s2mm_tlast,
    input wire m00_axis_real_s2mm_tready,
    output reg m00_axis_real_s2mm_tvalid,

    output reg [MDATA_WIDTH-1:0] m00_axis_imag_s2mm_tdata,
    output reg [SDATA_WIDTH/SSAMPLE_WIDTH-1:0] m00_axis_imag_s2mm_tkeep,
    output reg m00_axis_imag_s2mm_tlast,
    input wire m00_axis_imag_s2mm_tready,
    output reg m00_axis_imag_s2mm_tvalid,
    /*-------------------------Channel01 Output Real & Imag-------------------------*/
    output reg [MDATA_WIDTH-1:0] m01_axis_real_s2mm_tdata,
    output reg [SDATA_WIDTH/SSAMPLE_WIDTH-1:0] m01_axis_real_s2mm_tkeep,
    output reg m01_axis_real_s2mm_tlast,
    input wire m01_axis_real_s2mm_tready,
    output reg m01_axis_real_s2mm_tvalid,

    output reg [MDATA_WIDTH-1:0] m01_axis_imag_s2mm_tdata,
    output reg [SDATA_WIDTH/SSAMPLE_WIDTH-1:0] m01_axis_imag_s2mm_tkeep,
    output reg m01_axis_imag_s2mm_tlast,
    input wire m01_axis_imag_s2mm_tready,
    output reg m01_axis_imag_s2mm_tvalid,
    /*-------------------------Channel20 Output Real & Imag-------------------------*/
    output reg [MDATA_WIDTH-1:0] m20_axis_real_s2mm_tdata,
    output reg [SDATA_WIDTH/SSAMPLE_WIDTH-1:0] m20_axis_real_s2mm_tkeep,
    output reg m20_axis_real_s2mm_tlast,
    input wire m20_axis_real_s2mm_tready,
    output reg m20_axis_real_s2mm_tvalid,

    output reg [MDATA_WIDTH-1:0] m20_axis_imag_s2mm_tdata,
    output reg [SDATA_WIDTH/SSAMPLE_WIDTH-1:0] m20_axis_imag_s2mm_tkeep,
    output reg m20_axis_imag_s2mm_tlast,
    input wire m20_axis_imag_s2mm_tready,
    output reg m20_axis_imag_s2mm_tvalid,
    /*-------------------------Channel21 Output Real & Imag-------------------------*/
    output reg [MDATA_WIDTH-1:0] m21_axis_real_s2mm_tdata,
    output reg [SDATA_WIDTH/SSAMPLE_WIDTH-1:0] m21_axis_real_s2mm_tkeep,
    output reg m21_axis_real_s2mm_tlast,
    input wire m21_axis_real_s2mm_tready,
    output reg m21_axis_real_s2mm_tvalid,

    output reg [MDATA_WIDTH-1:0] m21_axis_imag_s2mm_tdata,
    output reg [SDATA_WIDTH/SSAMPLE_WIDTH-1:0] m21_axis_imag_s2mm_tkeep,
    output reg m21_axis_imag_s2mm_tlast,
    input wire m21_axis_imag_s2mm_tready,
    output reg m21_axis_imag_s2mm_tvalid
/*======================================END OUTPUTS=======================================*/
    );

    integer samples = SDATA_WIDTH/SSAMPLE_WIDTH;

    integer i;

    // we need bit overflow for the following 2's complement arithmetic:
    //       reg[SSAMPLE_WIDTH] * reg[WEIGHT_WIDTH] + reg2[SSAMPLE_WIDTH] * reg2[WEIGHT_WIDTH] => 
    //          we need dataBuffer of size SSAMPLE_WIDTH+WEIGHT_WIDTH+1
    reg [SSAMPLE_WIDTH+WEIGHT_WIDTH+1-1:0]dataBuffer; // with SSAMPLE_WIDTH=16 and WEIGHT_WIDTH=8, dataBuffer needs 25 bits

    reg [SSAMPLE_WIDTH+3-1:0]dataBuffer_Sum;

    // pipelining for weights to help pass timing
    reg [7:0] bw00_re = 8'd0; reg [7:0] bw00_im = 8'd0;
    reg [7:0] bw01_re = 8'd0; reg [7:0] bw01_im = 8'd0;
    reg [7:0] bw20_re = 8'd0; reg [7:0] bw20_im = 8'd0;
    reg [7:0] bw21_re = 8'd0; reg [7:0] bw21_im = 8'd0;
    
    
    always @(posedge clock) begin
        //~resetn
        if (resetn == 1'b0) begin
            // data out, valid, tread, and tlast should all be 0
            m00_axis_real_s2mm_tdata = 0;   m00_axis_imag_s2mm_tdata = 0;
            m00_axis_real_s2mm_tvalid = 0;  m00_axis_imag_s2mm_tvalid = 0;
            s00_axis_real_tready = 0;       s00_axis_imag_tready = 0;
            m00_axis_real_s2mm_tlast = 0;   m00_axis_imag_s2mm_tlast = 0;

            m01_axis_real_s2mm_tdata = 0;   m01_axis_imag_s2mm_tdata = 0;
            m01_axis_real_s2mm_tvalid = 0;  m01_axis_imag_s2mm_tvalid = 0;
            s01_axis_real_tready = 0;       s01_axis_imag_tready = 0;
            m01_axis_real_s2mm_tlast = 0;   m01_axis_imag_s2mm_tlast = 0;

            m20_axis_real_s2mm_tdata = 0;   m20_axis_imag_s2mm_tdata = 0;
            m20_axis_real_s2mm_tvalid = 0;  m20_axis_imag_s2mm_tvalid = 0;
            s20_axis_real_tready = 0;       s20_axis_imag_tready = 0;
            m20_axis_real_s2mm_tlast = 0;   m20_axis_imag_s2mm_tlast = 0;

            m21_axis_real_s2mm_tdata = 0;   m21_axis_imag_s2mm_tdata = 0;
            m21_axis_real_s2mm_tvalid = 0;  m21_axis_imag_s2mm_tvalid = 0;
            s21_axis_real_tready = 0;       s21_axis_imag_tready = 0;
            m21_axis_real_s2mm_tlast = 0;   m21_axis_imag_s2mm_tlast = 0;
        end
        else begin
            // setting beamforming weight registers for pipelining
            bw00_re <= bWeight00_real; bw00_im <= bWeight00_imag;
            bw01_re <= bWeight01_real; bw01_im <= bWeight01_imag;
            bw20_re <= bWeight20_real; bw20_im <= bWeight20_imag;
            bw21_re <= bWeight00_real; bw21_im <= bWeight00_imag;

            /*------------------------CHANNEL 00 READY/VALID------------------------*/
            if (m00_axis_real_s2mm_tready && s00_axis_real_tvalid && m00_axis_imag_s2mm_tready && s00_axis_imag_tvalid) begin
                // tkeep and tvalid are now high (tkeep = 16'hffff, tvalid = 1'b1)
                m00_axis_real_s2mm_tkeep <= 16'hffff;   m00_axis_imag_s2mm_tkeep <= 16'hffff;
                m00_axis_real_s2mm_tvalid <= 1'b1;      m00_axis_imag_s2mm_tvalid <= 1'b1;

                // this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
                for(i=0; i<samples; i = i+1) begin
                    // this can be a non-blocking assignment because there is a blocking assignment in the incrementing of i
                    // multiply by appropriate weight, accounting for complex/real parts of weight
                    dataBuffer <= bw00_re*s00_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]
                        + bw00_im*s00_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]; 
                    // rounding real data using bit 8
                    if (dataBuffer[WEIGHT_WIDTH] == 0) begin
                        m00_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH];
                    end
                    else if (dataBuffer[WEIGHT_WIDTH] == 1) begin
                        m00_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH] + 1'b1;
                    end

                    dataBuffer <= bw00_im*s00_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]
                        + bw00_re*s00_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
                    // rounding imaginary data using bit 8
                    if (dataBuffer[WEIGHT_WIDTH] == 0) begin
                        m00_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH];
                    end
                    else if (dataBuffer[WEIGHT_WIDTH] == 1) begin
                        // accounting for overflow if dataBuffer = 19'b1 or dataBuffer = 
                        // what if there is bit overflow here? is this likely enough to plan for an extra bit?
                        m00_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH] + 1'b1;
                    end
                end
            end
            /*----------------------CHANNEL 00 NOT READY/VALID----------------------*/
            else begin 
                // invalid data, so output data is set to static value of 0
                m00_axis_real_s2mm_tdata <= 128'b0;
                m00_axis_imag_s2mm_tdata <= 128'b0;

                // output valid and output tkeep should be low
                m00_axis_real_s2mm_tvalid <= 0; m00_axis_imag_s2mm_tvalid <= 0;
                m00_axis_real_s2mm_tkeep <= 0;  m00_axis_imag_s2mm_tkeep <= 0;
            end
            /*------------------------CHANNEL 01 READY/VALID------------------------*/
            if (m01_axis_real_s2mm_tready && s01_axis_real_tvalid && m01_axis_imag_s2mm_tready && s01_axis_imag_tvalid) begin
                // tkeep and tvalid are now high (tkeep = 16'hffff, tvalid = 1'b1)
                m01_axis_real_s2mm_tkeep <= 16'hffff;   m01_axis_imag_s2mm_tkeep <= 16'hffff;
                m01_axis_real_s2mm_tvalid <= 1'b1;      m01_axis_imag_s2mm_tvalid <= 1'b1;

                // this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
                for(i=0; i<samples; i = i+1) begin
                    // this can be a non-blocking assignment because there is a blocking assignment in the incrementing of i
                    // multiply by appropriate weight, accounting for complex/real parts of weight
                    dataBuffer <= bw01_re*s01_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]
                        + bw01_im*s01_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]; 
                    // rounding real data using bit 8
                    if (dataBuffer[WEIGHT_WIDTH] == 0) begin
                        m01_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH];
                    end
                    else if (dataBuffer[WEIGHT_WIDTH] == 1) begin
                        m01_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH] + 1'b1;
                    end

                    dataBuffer <= bw01_im*s01_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]
                        + bw01_re*s01_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
                    // rounding imaginary data using bit 8
                    if (dataBuffer[WEIGHT_WIDTH] == 0) begin
                        m01_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH];
                    end
                    else if (dataBuffer[WEIGHT_WIDTH] == 1) begin
                        // what if there is bit overflow here? is this likely enough to plan for an extra bit?
                        m01_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH] + 1'b1;
                    end
                end
            end
            /*----------------------CHANNEL 01 NOT READY/VALID----------------------*/
            else begin 
                // invalid data, so output data is set to static value of 0
                m01_axis_real_s2mm_tdata <= 128'b0;
                m01_axis_imag_s2mm_tdata <= 128'b0;

                // output valid and output tkeep should be low
                m01_axis_real_s2mm_tvalid <= 0; m01_axis_imag_s2mm_tvalid <= 0;
                m01_axis_real_s2mm_tkeep <= 0;  m01_axis_imag_s2mm_tkeep <= 0;
            end
            /*------------------------CHANNEL 20 READY/VALID------------------------*/
            if (m20_axis_real_s2mm_tready && s20_axis_real_tvalid && m20_axis_imag_s2mm_tready && s20_axis_imag_tvalid) begin
                // tkeep and tvalid are now high (tkeep = 16'hffff, tvalid = 1'b1)
                m20_axis_real_s2mm_tkeep <= 16'hffff;   m20_axis_imag_s2mm_tkeep <= 16'hffff;
                m20_axis_real_s2mm_tvalid <= 1'b1;      m20_axis_imag_s2mm_tvalid <= 1'b1;

                // this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
                for(i=0; i<samples; i = i+1) begin
                    // this can be a non-blocking assignment because there is a blocking assignment in the incrementing of i
                    // multiply by appropriate weight, accounting for complex/real parts of weight
                    dataBuffer <= bw20_re*s20_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]
                        + bw20_im*s20_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]; 
                    // rounding real data using bit 8
                    if (dataBuffer[WEIGHT_WIDTH] == 0) begin
                        m20_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH];
                    end
                    else if (dataBuffer[WEIGHT_WIDTH] == 1) begin
                        m20_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH] + 1'b1;
                    end

                    dataBuffer <= bw20_im*s20_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]
                        + bw20_re*s20_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
                    // rounding imaginary data using bit 8
                    if (dataBuffer[WEIGHT_WIDTH] == 0) begin
                        m20_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH];
                    end
                    else if (dataBuffer[WEIGHT_WIDTH] == 1) begin
                        // what if there is bit overflow here? is this likely enough to plan for an extra bit?
                        m20_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH] + 1'b1;
                    end
                end
            end
            /*----------------------CHANNEL 20 NOT READY/VALID----------------------*/
            else begin 
                // invalid data, so output data is set to static value of 0
                m20_axis_real_s2mm_tdata <= 128'b0;
                m20_axis_imag_s2mm_tdata <= 128'b0;

                // output valid and output tkeep should be low
                m20_axis_real_s2mm_tvalid <= 0; m20_axis_imag_s2mm_tvalid <= 0;
                m20_axis_real_s2mm_tkeep <= 0;  m20_axis_imag_s2mm_tkeep <= 0;
            end
            /*------------------------CHANNEL 21 READY/VALID------------------------*/
            if (m21_axis_real_s2mm_tready && s21_axis_real_tvalid && m21_axis_imag_s2mm_tready && s21_axis_imag_tvalid) begin
                // tkeep and tvalid are now high (tkeep = 16'hffff, tvalid = 1'b1)
                m21_axis_real_s2mm_tkeep <= 16'hffff;   m21_axis_imag_s2mm_tkeep <= 16'hffff;
                m21_axis_real_s2mm_tvalid <= 1'b1;      m21_axis_imag_s2mm_tvalid <= 1'b1;

                // this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
                for(i=0; i<samples; i = i+1) begin
                    // this can be a non-blocking assignment because there is a blocking assignment in the incrementing of i
                    // multiply by appropriate weight, accounting for complex/real parts of weight
                    dataBuffer <= bw21_re*s21_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]
                        + bw21_im*s21_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]; 
                    // rounding real data using bit 8
                    if (dataBuffer[WEIGHT_WIDTH] == 0) begin
                        m21_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH];
                    end
                    else if (dataBuffer[WEIGHT_WIDTH] == 1) begin
                        m21_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH] + 1'b1;
                    end

                    dataBuffer <= bw21_im*s21_axis_real_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH]
                        + bw21_re*s21_axis_imag_tdata[i*SSAMPLE_WIDTH +: SSAMPLE_WIDTH];
                    // rounding imaginary data using bit 8
                    if (dataBuffer[WEIGHT_WIDTH] == 0) begin
                        m21_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH];
                    end
                    else if (dataBuffer[WEIGHT_WIDTH] == 1) begin
                        // what if there is bit overflow here? is this likely enough to plan for an extra bit?
                        m21_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer[SSAMPLE_WIDTH+WEIGHT_WIDTH -: SSAMPLE_WIDTH] + 1'b1;
                    end
                end
            end
            /*----------------------CHANNEL 21 NOT READY/VALID----------------------*/
            else begin 
                // invalid data, so output data is set to static value of 0
                m21_axis_real_s2mm_tdata <= 128'b0;
                m21_axis_imag_s2mm_tdata <= 128'b0;

                // output valid and output tkeep should be low
                m21_axis_real_s2mm_tvalid <= 0; m21_axis_imag_s2mm_tvalid <= 0;
                m21_axis_real_s2mm_tkeep <= 0;  m21_axis_imag_s2mm_tkeep <= 0;
            end

            /* 1. This implementation of the Adder assumes that if one channel has valid data, so do the rest of the channels
             * The data it produces should be accurate, but given how I'm rounding the data, the firmware may be faster
             * and more precise if I only sum the data if two or more channels have valid data.
             *
             * 2. Additionally, the data may be more precise if I round based on how many channels have valid data (that we are summing)
             */
            if((m00_axis_real_s2mm_tready && s00_axis_real_tvalid) || (m01_axis_real_s2mm_tready && s01_axis_real_tvalid) ||
               (m20_axis_real_s2mm_tready && s20_axis_real_tvalid) || (m20_axis_real_s2mm_tready && s00_axis_real_tvalid) ||
               (m00_axis_imag_s2mm_tready && s00_axis_imag_tvalid) || (m01_axis_imag_s2mm_tready && s01_axis_imag_tvalid) ||
               (m20_axis_imag_s2mm_tready && s20_axis_imag_tvalid) || (m20_axis_imag_s2mm_tready && s00_axis_imag_tvalid)) begin
                // this for loop multiplies every eight bits by bWeights (it'll loop 16 times- 1 time per sample in tdata)
                for(i=0; i<samples; i = i+1) begin
                    // this can be a non-blocking assignment because there is a blocking assignment in the incrementing of i
                    dataBuffer_Sum = m00_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] + m01_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH]
                        + m20_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] + m21_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH];
                    if (dataBuffer_Sum[2] == 1'b1) begin // round up
                        // same thing as above- we could overflow here but are we really worried about that?
                        m00_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] = dataBuffer_Sum[MSAMPLE_WIDTH+3-1 -: MSAMPLE_WIDTH] + 1'b1;
                    end
                    else begin // round down
                        m00_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] = dataBuffer_Sum[MSAMPLE_WIDTH+3-1 -: MSAMPLE_WIDTH];
                    end

                    dataBuffer_Sum = m00_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] + m01_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH]
                        + m20_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] + m21_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH];
                    if (dataBuffer_Sum[2] == 1'b1) begin // round up
                        // same thing as above- we could overflow here but are we really worried about that?
                        m00_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] = dataBuffer_Sum[MSAMPLE_WIDTH+3-1 -: MSAMPLE_WIDTH] + 1'b1;
                    end
                    else begin // round down
                        m00_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] = dataBuffer_Sum[MSAMPLE_WIDTH+3-1 -: MSAMPLE_WIDTH];
                    end
                end
            end
         end
    end
endmodule
