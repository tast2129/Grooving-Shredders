#include "Beamforming.hpp"
#include "hls_math.h"
#include "vt_fft.hpp"
#include <complex.h>

/*
 * Calculate the delays required for each antenna element in a linear array based on the input angle.
 *
Parameters:
	in1, in2, in3, in4 (complex): Antenna signals (received)
	steeringAngle (float): The angle of arrival of the signal in degrees (the beamsteering angle)
	frequency (float): The frequency of the signal in Hz. Default is 1.24 GHz.

Returns:
	the combined/weighted signal received by the phased array
*/
#define MAX_SIZE 4

dout_t sum_and_delay(din_t in1, din_t in2, din_t in3, din_t in4, din_t steeringAngle, din_t frequency) {
	dout_t weighted_signal;
	float c, v, wavelength, d, angle_rad, pi;
	complex bWeights0;

	complex inputSig[1][4];
	#pragma HLS ARRAY_PARTITION variable=inputSig dim=0 complete
	inputSig = {in1, in2, in3, in4};

	complex bWeights[4][1];
	#pragma HLS ARRAY_PARTITION variable=bWeights dim=0 complete

	complex weightedSig[1][1];
	#pragma HLS ARRAY_PARTITION variable=weightedSig dim = 0 complete

#pragma HLS ARRAY_PARTITION variable=b type=complete dim=1
#pragma HLS ARRAY_PARTITION variable=inputSig type=complete dim=1

	// Constants
	c = 3e8; 		// in a vacuum, [m/s]
	v = c * 0.9997; // in air [m/s]
	pi = 3.141592653589;
	
	// Calculate wavelength
    wavelength = v / frequency;

    // Determine the spacing between antenna elements
    d = wavelength / 2;

    // Convert angle from degrees to radians
    angle_rad = steeringAngle * pi / 180;

    // Calculate delay
    //delay = (d * sin(angle_rad)) / c; // in seconds

    bWeights0 = exp(-2 * _Imaginary_I * pi * d * bWeights0 * sin(angle_rad));
    bWeights = {bWeights0^0, bWeights0^1, bWeights0^2, bWeights0^3};

    // adapted from https://xilinx.github.io/Vitis_Accel_Examples/2019.2/html/systolic_array.html
    systolic1:
        for (int k = 0; k < a_col; k++) {
           #pragma HLS LOOP_TRIPCOUNT min=c_size max=c_size
           #pragma HLS PIPELINE II=1
        systolic2:
            for (int i = 0; i < MAX_SIZE; i++) {
            systolic3:
                for (int j = 0; j < MAX_SIZE; j++) {
                    int last = (k == 0) ? 0 : weightedSig[i][j];
                    int in_val = (i < a_row && k < a_col) ? inputSig[i][k] : 0;
                    int b_val = (k < b_row && j < b_col) ? bWeights[k][j] : 0;
                    int result = last + in_val * b_val;

                    weightedSig[i][j] = result;
                }
            }
        }

    // alternatively ->
    weightedSig = bWeights[1][1] * in1 + bWeights[1][2] * in2 + bWeights[1][3] * in3 + bWeights[1][4] * in4;


 	return weighted_signal;
}
