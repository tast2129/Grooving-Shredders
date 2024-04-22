/* 
 * AXI stream multiplier block taking 128-bit input data and summing it
*/
module axis_adder
  #(
    parameter SDATA_WIDTH = 128,
    parameter SSAMPLE_WIDTH = 16,
    parameter WEIGHT_WIDTH = 8,
    parameter MSAMPLE_WIDTH = 16,   // SSAMPLE_WIDTH + WEIGHT_WIDTH
    parameter MDATA_WIDTH = 128,     // MSAMPLE_WIDTH * SAMPLES
    parameter BUFFER_WIDTH = SSAMPLE_WIDTH+WEIGHT_WIDTH,
    parameter SUM_BUFFER = MSAMPLE_WIDTH+3,
    parameter SAMPLES = SDATA_WIDTH/SSAMPLE_WIDTH
   ) 
    (
/*======================================BEGIN INPUTS=======================================*/
    input wire clock,
    input wire resetn,
    
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

    // reg [((SSAMPLE_WIDTH+3)-1)*SAMPLES:0]dataBuffer_Sum;
    reg [SUM_BUFFER*SAMPLES:0]dataBuffer_SumRe = 0;
    reg [SUM_BUFFER*SAMPLES:0]dataBuffer_SumIm = 0;

    always @(posedge clock) begin
        //~resetn
        if (resetn == 1'b0) begin
            // data out, valid, tready, and tlast should all be 0
            m00_axis_real_s2mm_tdata <= {MDATA_WIDTH{0}};   m00_axis_imag_s2mm_tdata <= {MDATA_WIDTH{0}};
            m00_axis_real_s2mm_tvalid <= 1'b0;              m00_axis_imag_s2mm_tvalid <= 1'b0;
            s00_axis_real_tready <= 1'b0;                   s00_axis_imag_tready <= 1'b0;
            m00_axis_real_s2mm_tlast <= 1'b0;               m00_axis_imag_s2mm_tlast <= 1'b0;

            m01_axis_real_s2mm_tdata <= {MDATA_WIDTH{0}};   m01_axis_imag_s2mm_tdata <= {MDATA_WIDTH{0}};
            m01_axis_real_s2mm_tvalid <= 1'b0;              m01_axis_imag_s2mm_tvalid <= 1'b0;
            s01_axis_real_tready <= 1'b0;                   s01_axis_imag_tready <= 1'b0;
            m01_axis_real_s2mm_tlast <= 1'b0;               m01_axis_imag_s2mm_tlast <= 1'b0;

            m20_axis_real_s2mm_tdata <= {MDATA_WIDTH{0}};   m20_axis_imag_s2mm_tdata <= {MDATA_WIDTH{0}};
            m20_axis_real_s2mm_tvalid <= 1'b0;              m20_axis_imag_s2mm_tvalid <= 1'b0;
            s20_axis_real_tready <= 1'b0;                   s20_axis_imag_tready <= 1'b0;
            m20_axis_real_s2mm_tlast <= 1'b0;               m20_axis_imag_s2mm_tlast <= 1'b0;

            m21_axis_real_s2mm_tdata <= {MDATA_WIDTH{0}};   m21_axis_imag_s2mm_tdata <= {MDATA_WIDTH{0}};
            m21_axis_real_s2mm_tvalid <= 1'b0;              m21_axis_imag_s2mm_tvalid <= 1'b0;
            s21_axis_real_tready <= 1'b0;                   s21_axis_imag_tready <= 1'b0;
            m21_axis_real_s2mm_tlast <= 1'b0;               m21_axis_imag_s2mm_tlast <= 1'b0;
        end
        else begin
            // if all the channels have valid data, then sum them
            if ((s00_axis_real_tvalid && s00_axis_imag_tvalid) && (s01_axis_real_tvalid && s01_axis_imag_tvalid) &&
                (s20_axis_real_tvalid && s20_axis_imag_tvalid) && (s21_axis_real_tvalid && s21_axis_imag_tvalid)) begin

                // this for loop sums every eight bit sample of each channel (it'll loop 8 times- 1 time per sample in tdata)
                for(i=0; i<SAMPLES; i = i+1) begin
                    // rounding the two sums from above by using the LSBs (twos complement addition produces a sum in which we can ignore bit overflow)
                    dataBuffer_SumRe[i*SUM_BUFFER +: SUM_BUFFER] <= s00_axis_real_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] + s01_axis_real_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH]
                                 + s20_axis_real_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] + s21_axis_real_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH];
                    
                    // sum of real, weighted data (m00 + m01 + m20 + m21)
                    m00_axis_real_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer_SumRe[i*SUM_BUFFER +: MSAMPLE_WIDTH];
                    
                    // rounding the two sums from above by using the LSBs (twos complement addition produces a sum in which we can ignore bit overflow)
                    dataBuffer_SumIm[i*SUM_BUFFER +: SUM_BUFFER] <= s00_axis_imag_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] + s01_axis_imag_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH]
                                                         +  s20_axis_imag_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] + s21_axis_imag_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH];
                    // sum of imaginary, weighted data (m00 + m01 + m20 + m21)
                    m00_axis_imag_s2mm_tdata[i*MSAMPLE_WIDTH +: MSAMPLE_WIDTH] <= dataBuffer_SumIm[i*SUM_BUFFER +: MSAMPLE_WIDTH];
                end

                // keep all sample bytes
                m00_axis_real_s2mm_tkeep <= {SAMPLES{1'b1}};
                m00_axis_imag_s2mm_tkeep <= {SAMPLES{1'b1}};
                m00_axis_real_s2mm_tvalid <= 1'b1;                     
                m00_axis_imag_s2mm_tvalid <= 1'b1;
                m00_axis_real_s2mm_tlast <= s00_axis_real_tlast;
                m00_axis_imag_s2mm_tlast <= s00_axis_imag_tlast;
            end
            // making sure channel00 has output data if not all of the channels have valid data
            else begin 
                assign m00_axis_real_s2mm_tdata = s00_axis_real_tdata; 
                assign m00_axis_real_s2mm_tkeep = {SAMPLES{s00_axis_real_tvalid}}; 
                assign m00_axis_real_s2mm_tvalid = s00_axis_real_tvalid; 
                assign m00_axis_real_s2mm_tlast = s00_axis_real_tlast;
                assign s00_axis_real_tready = m00_axis_real_s2mm_tready;

                assign m00_axis_imag_s2mm_tdata = s00_axis_imag_tdata;
                assign m00_axis_imag_s2mm_tkeep = {SAMPLES{s00_axis_imag_tvalid}};
                assign m00_axis_imag_s2mm_tvalid = s00_axis_imag_tvalid;
                assign m00_axis_imag_s2mm_tlast = s00_axis_imag_tlast;
                assign s00_axis_imag_tready = m00_axis_imag_s2mm_tready;
            end

            // for channel01, channel20, and channel21 -> outputs = inputs
            assign m01_axis_real_s2mm_tdata = s01_axis_real_tdata; 
            assign m01_axis_real_s2mm_tkeep = {SAMPLES{s01_axis_real_tvalid}};   
            assign m01_axis_real_s2mm_tvalid = s01_axis_real_tvalid; 
            assign m01_axis_real_s2mm_tlast = s01_axis_real_tlast;
            assign s01_axis_real_tready = m01_axis_real_s2mm_tready;

            assign m01_axis_imag_s2mm_tdata = s01_axis_imag_tdata;  
            assign m01_axis_imag_s2mm_tkeep = {SAMPLES{s01_axis_imag_tvalid}};  
            assign m01_axis_imag_s2mm_tvalid = s01_axis_imag_tvalid;
            assign m01_axis_imag_s2mm_tlast = s01_axis_imag_tlast;
            assign s01_axis_imag_tready = m01_axis_imag_s2mm_tready;

            assign m20_axis_real_s2mm_tdata = s20_axis_real_tdata;  
            assign m20_axis_real_s2mm_tkeep = {SAMPLES{s20_axis_real_tvalid}};  
            assign m20_axis_real_s2mm_tvalid = s20_axis_real_tvalid; 
            assign m20_axis_real_s2mm_tlast = s20_axis_real_tlast;
            assign s20_axis_real_tready = m20_axis_real_s2mm_tready;

            assign m20_axis_imag_s2mm_tdata = s20_axis_imag_tdata;
            assign m20_axis_imag_s2mm_tkeep = {SAMPLES{s20_axis_imag_tvalid}};    
            assign m20_axis_imag_s2mm_tvalid = s20_axis_imag_tvalid;
            assign m20_axis_imag_s2mm_tlast = s20_axis_imag_tlast;
            assign s20_axis_imag_tready = m20_axis_imag_s2mm_tready;

            assign m21_axis_real_s2mm_tdata = s21_axis_real_tdata;   
            assign m21_axis_real_s2mm_tkeep = {SAMPLES{s21_axis_real_tvalid}}; 
            assign m21_axis_real_s2mm_tvalid = s21_axis_real_tvalid; 
            assign m21_axis_real_s2mm_tlast = s21_axis_real_tlast;
            assign s21_axis_real_tready = m21_axis_real_s2mm_tready;

            assign m21_axis_imag_s2mm_tdata = s21_axis_imag_tdata;
            assign m21_axis_imag_s2mm_tkeep = {SAMPLES{s21_axis_imag_tvalid}};    
            assign m21_axis_imag_s2mm_tvalid = s21_axis_imag_tvalid;
            assign m21_axis_imag_s2mm_tlast = s21_axis_imag_tlast;
            assign s21_axis_imag_tready = m21_axis_imag_s2mm_tready;
        end
    end
endmodule