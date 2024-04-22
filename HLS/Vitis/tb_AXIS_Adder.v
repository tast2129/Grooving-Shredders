/* testbench for AXIS_Adder
 * Katie Christiansen, 4/17/2024
 */

 module tb_AXIS_Adder;

    wire clk;
    reg signed [7:0]bw00_re; reg signed [7:0]bw00_im;
    reg signed [7:0]bw01_re; reg signed [7:0]bw01_im;
    reg signed [7:0]bw20_re; reg signed [7:0]bw20_im;
    reg signed [7:0]bw21_re; reg signed [7:0]bw21_im;

    reg [127:0] s00_tdata_re; reg [127:0] s00_tdata_im;
    reg [127:0] s01_tdata_re; reg [127:0] s01_tdata_im;
    reg [127:0] s20_tdata_re; reg [127:0] s20_tdata_im;
    reg [127:0] s21_tdata_re; reg [127:0] s21_tdata_im; 
    reg [127:0] m00_tdata_re; reg [127:0] m00_tdata_im;
    reg [127:0] m01_tdata_re; reg [127:0] m01_tdata_im;
    reg [127:0] m20_tdata_re; reg [127:0] m20_tdata_im;
    reg [127:0] m21_tdata_re; reg [127:0] m21_tdata_im; 


    initial begin
        /* 
        bw00_re <= 1*127;
        bw00_im <= 0;
        bw01_re <= 0.68724692*127; // 87.28035884
        bw01_im <= -0.72642389*127;
        bw20_re <= -0.05538334*127;
        bw20_im <= -0.99846516*127;
        bw21_re <= -0.76337098*127;
        bw21_im <= -0.64596033*127;*/

        s00_tdata_re = {8{16'hA0}};
        s00_tdata_im = {8{16'hB0}};
        s01_tdata_re = {8{16'hC0}};
        s01_tdata_im = {8{16'hD0}};
        s20_tdata_re = {8{16'hA0}};
        s20_tdata_im = {8{16'hB0}};
        s21_tdata_re = {8{16'hC0}};
        s21_tdata_im = {8{16'hD0}};

        clk = 1'b0;
        forever begin
            #1 clk = ~clk;
        end
    end

 AXIS_Adder adder ( .clock(clk),
                    .resetn(0),

                    // for beamsteering to 15 degrees from broadside
                    .bWeight00_real(bw00_re), // = 1
                    .bWeight00_imag(bw00_im), // = 0
                    .bWeight01_real(bw01_re), // = 0.68724692
                    .bWeight01_imag(bw01_im), // = -0.72642389
                    .bWeight20_real(bw20_re), // = -0.05538334
                    .bWeight20_imag(bw20_im), // = -0.99846516
                    .bWeight21_real(bw21_re), // = -0.76337098
                    .bWeight21_imag(bw21_im), // = -0.64596033
                    /*-------------------------Channel00 Input Real & Imag-------------------------*/
                    .s00_axis_real_tvalid(1),
                    .s00_axis_real_tready(1),
                    .s00_axis_real_tdata(s00_tdata_re), // 8 16-bit samples
                    .s00_axis_real_tlast(0),
                    .s00_axis_imag_tvalid(1),
                    .s00_axis_imag_tready(1),
                    .s00_axis_imag_tdata(s00_tdata_im), // 8 16-bit samples
                    .s00_axis_imag_tlast(0),
                    /*-------------------------Channel01 Input Real & Imag-------------------------*/
                    .s01_axis_real_tvalid(1),
                    .s01_axis_real_tready(1),
                    .s01_axis_real_tdata(s01_tdata_re), // 8 16-bit samples
                    .s01_axis_real_tlast(0),
                    .s01_axis_imag_tvalid(1),
                    .s01_axis_imag_tready(1),
                    .s01_axis_imag_tdata(s01_tdata_im), // 16 8-bit samples
                    .s01_axis_imag_tlast(0),
                    /*-------------------------Channel20 Input Real & Imag-------------------------*/
                    .s20_axis_real_tvalid(1),
                    .s20_axis_real_tready(1),
                    .s20_axis_real_tdata(s20_tdata_re), // 16 8-bit samples
                    .s20_axis_real_tlast(0),
                    .s20_axis_imag_tvalid(1),
                    .s20_axis_imag_tready(1),
                    .s20_axis_imag_tdata(s20_tdata_im), // 16 8-bit samples
                    .s20_axis_imag_tlast(0),
                    /*-------------------------Channel21 Input Real & Imag-------------------------*/
                    .s21_axis_real_tvalid(1),
                    .s21_axis_real_tready(1),
                    .s21_axis_real_tdata(s21_tdata_re), // 16 8-bit samples
                    .s21_axis_real_tlast(0),
                    .s21_axis_imag_tvalid(1),
                    .s21_axis_imag_tready(1),
                    .s21_axis_imag_tdata(s21_tdata_im), // 16 8-bit samples
                    .s21_axis_imag_tlast(0),
                    /*=======================================END INPUTS=======================================*/

                    /*=====================================BEGIN OUTPUTS======================================*/
                    /*-------------------------Channel00 Output Real & Imag-------------------------*/
                    .m00_axis_real_s2mm_tdata(m00_tdata_re),
                    .m00_axis_real_s2mm_tkeep(16'hfff),
                    .m00_axis_real_s2mm_tlast(0),
                    .m00_axis_real_s2mm_tready(1),
                    .m00_axis_real_s2mm_tvalid(1),
                    .m00_axis_imag_s2mm_tdata(m00_tdata_re),
                    .m00_axis_imag_s2mm_tkeep(16'hfff),
                    .m00_axis_imag_s2mm_tlast(0),
                    .m00_axis_imag_s2mm_tready(1),
                    .m00_axis_imag_s2mm_tvalid(1),
                    /*-------------------------Channel01 Output Real & Imag-------------------------*/
                    .m01_axis_real_s2mm_tdata(m01_tdata_re),
                    .m01_axis_real_s2mm_tkeep(16'hfff),
                    .m01_axis_real_s2mm_tlast(0),
                    .m01_axis_real_s2mm_tready(1),
                    .m01_axis_real_s2mm_tvalid(1),
                    .m01_axis_imag_s2mm_tdata(m01_tdata_im),
                    .m01_axis_imag_s2mm_tkeep(16'hfff),
                    .m01_axis_imag_s2mm_tlast(0),
                    .m01_axis_imag_s2mm_tready(1),
                    .m01_axis_imag_s2mm_tvalid(1),
                    /*-------------------------Channel20 Output Real & Imag-------------------------*/
                    .m20_axis_real_s2mm_tdata(m20_tdata_re),
                    .m20_axis_real_s2mm_tkeep(16'hfff),
                    .m20_axis_real_s2mm_tlast(0),
                    .m20_axis_real_s2mm_tready(1),
                    .m20_axis_real_s2mm_tvalid(1),   
                    .m20_axis_imag_s2mm_tdata(m21_tdata_im),
                    .m20_axis_imag_s2mm_tkeep(16'hfff),
                    .m20_axis_imag_s2mm_tlast(0),
                    .m20_axis_imag_s2mm_tready(1),
                    .m20_axis_imag_s2mm_tvalid(1),
                    /*-------------------------Channel21 Output Real & Imag-------------------------*/
                    .m21_axis_real_s2mm_tdata(m21_tdata_re),
                    .m21_axis_real_s2mm_tkeep(16'hfff),
                    .m21_axis_real_s2mm_tlast(0),
                    .m21_axis_real_s2mm_tready(1),
                    .m21_axis_real_s2mm_tvalid(1),
                    .m21_axis_imag_s2mm_tdata(m21_tdata_im),
                    .m21_axis_imag_s2mm_tkeep(16'hfff),
                    .m21_axis_imag_s2mm_tlast(0),
                    .m21_axis_imag_s2mm_tready(1),
                    .m21_axis_imag_s2mm_tvalid(1)
                    /*======================================END OUTPUTS=======================================*/
                )



 endmodule