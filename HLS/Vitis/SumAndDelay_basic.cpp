#include "Beamforming.hpp"
#include "hls_math.h"
#include <complex.h>

/*
 * Calculate the delays required for each antenna element in a linear array based on the input angle.
 *
Parameters:
	in1, in2, in3, in4 (complex): Antenna signals (received)
	bWeights[4] (float): Beamforming Weights array (calculated in python beamforming driver)
 
Returns:
	the combined/weighted signal received by the phased array
*/

dout_t sum_and_delay(din_t in1, din_t in2, din_t in3, din_t in4, din_t bWeights[4]) {
	#pragma HLS INTERFACE s_axilite port=in1 bundle=BUS_A
	#pragma HLS INTERFACE s_axilite port=in2 bundle=BUS_A
	#pragma HLS INTERFACE s_axilite port=in3 bundle=BUS_A
	#pragma HLS INTERFACE s_axilite port=in4 bundle=BUS_A

	#pragma HLS INTERFACE gpio port=bWeights bundle=BUS_A

	dout_t weighted_signal;
	#pragma HLS INTERFACE s_axilite port=weighted_signal bundle=BUS_A
	

    // alternatively ->
    weightedSig = bWeights[1][1] * in1 + bWeights[1][2] * in2 + bWeights[1][3] * in3 + bWeights[1][4] * in4;


 	return weighted_signal;
}
