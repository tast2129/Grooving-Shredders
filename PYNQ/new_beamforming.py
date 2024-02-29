# Imports
import numpy as np
import scipy
import scipy.signal as signal
import scipy.interpolate as interpolate
import matplotlib.pyplot as plt
import plotly.graph_objs as go
from plotly.subplots import make_subplots
from scipy.interpolate import CubicSpline
from scipy.signal import hilbert
import numpy as np
import ipywidgets as ipw
import base64
from random import randint
from pynq import Clocks
import xrfdc
import os
# Use the RFSoC overlay

from pynq.overlays.base import BaseOverlay

base = BaseOverlay('base.bit')



# Start RF clocks
base.init_rf_clks()

# Channels
#print("Transmitter channels:\n",base.radio.transmitter.get_channel_description())
DAC_CHANNEL_B = 0 # 'Channel 0': {'Tile': 224, 'Block': 0}
DAC_CHANNEL_A = 1 # 'Channel 1': {'Tile': 230, 'Block': 0}

#print("Receiver channels:\n",base.radio.receiver.get_channel_description())
ADC_CHANNEL_D = 0 # 'Channel 0': {'Tile': 224, 'Block': 0}
ADC_CHANNEL_C = 1 # 'Channel 1': {'Tile': 224, 'Block': 1}
ADC_CHANNEL_B = 2 # 'Channel 2': {'Tile': 226, 'Block': 0}
ADC_CHANNEL_A = 3 # 'Channel 3': {'Tile': 226, 'Block': 1}

adc_array = ['D', 'C', 'B', 'A']
# Set the center frequency and sampling frequency

print("Default and nonconfigurable ADC sampling frequency is 4915.2 MHz")
print("Default ADC mixing frequency is 1228.8 MHz")

# unused center_frequency = 1240e6  # Hz Frequency of carrier signal
number_samples = 32768  # Between 16 and 32768
decimation_factor = 1 # 2 is default
sample_frequency = 4915.2e6/decimation_factor  # Hz The default sample frequency is 4915.2e6 Hz which is sufficient for our signal

temp = base.radio.receiver.channel[ADC_CHANNEL_D].adc_block.MixerSettings
# print("Default ADC MixerSettings: ", base.radio.receiver.channel[ADC_CHANNEL_D].adc_block.MixerSettings)
# print("Default ADC DecimationFactor: ", base.radio.receiver.channel[ADC_CHANNEL_D].adc_block.DecimationFactor)

print(base.radio.receiver.channel[ADC_CHANNEL_D].adc_block.CoarseDelaySettings)
print(base.radio.receiver.channel[ADC_CHANNEL_D].adc_block.QMCSettings)
print(base.radio.receiver.channel[ADC_CHANNEL_D].adc_block.PwrMode)

def calculate_phase(signal):
    """
    Calculate the instantaneous phase of a sine signal using the Hilbert transform.

    Parameters:
    - signal: The input signal (either real data or interpolated data).

    Returns:
    - phase: The instantaneous phase of the signal in radians.
    """
    # Calculate the analytic signal from the real signal
    analytic_signal = hilbert(signal)
    
    # Calculate the instantaneous phase of the analytic signal
    instantaneous_phase = np.unwrap(np.angle(analytic_signal))
    
    average_phase = calculate_average_phase(instantaneous_phase)
    
    return average_phase

for ADC in range(0,len(base.radio.receiver.channel)):
# for ADC in range(2, ADC_CHANNEL_D+3): # Show only ADC D
    # if ADC == 2:
    #     continue
    base.radio.receiver.channel[ADC].adc_block.DecimationFactor = decimation_factor
    base.radio.receiver.channel[ADC].adc_block.MixerSettings = {
        'CoarseMixFreq':  xrfdc.COARSE_MIX_BYPASS,
        'EventSource':    xrfdc.EVNT_SRC_TILE, 
        'FineMixerScale': xrfdc.MIXER_SCALE_1P0,
        'Freq':           0.0,
        'MixerMode':      xrfdc.MIXER_MODE_R2C,
        'MixerType':      xrfdc.MIXER_TYPE_COARSE,
        'PhaseOffset':    0.0
    }
    base.radio.receiver.channel[ADC].adc_block.UpdateEvent(xrfdc.EVENT_MIXER)
    # base.radio.receiver.channel[ADC].adc_tile.SetupFIFO(True)
    
# Print mixer settings needed to inspect carrier
#print("ADC MixerSettings with both mixers bypassed: ", base.radio.receiver.channel[ADC_CHANNEL_D].adc_block.MixerSettings)

def calculate_average_phase(instantaneous_phase):
    """
    Calculate the average phase of a signal given its instantaneous phase.

    Parameters:
    - instantaneous_phase: The instantaneous phase of the signal in radians.

    Returns:
    - average_phase: The average phase of the signal in radians.
    """
    # Convert phase angles to complex numbers
    complex_numbers = np.exp(1j * instantaneous_phase)
    
    # Calculate the mean of the complex numbers
    mean_complex = np.mean(complex_numbers)
    
    # Calculate the angle of the mean complex number
    average_phase = np.angle(mean_complex)
    
    degrees_phase = np.degrees(average_phase)
    
    return average_phase

# Function to plot real and imaginary data in time domain
def plot_complex_time(data, n, fs=sample_frequency, 
                      title='Complex Time Plot'):
    plt_re_temp = (go.Scatter(x = np.arange(0, n/fs, 1/fs),
                              y = np.real(data), name='Real'))
    plt_im_temp = (go.Scatter(x = np.arange(0, n/fs, 1/fs),
                              y = np.imag(data), name='Imag'))
    return go.FigureWidget(data = [plt_re_temp, plt_im_temp],
                           layout = {'title': title, 
                                     'xaxis': {
                                         'title': 'Seconds (s)',
                                         'autorange' : True},
                                     'yaxis': {
                                         'title': 'Amplitude (V)'}})

def plot_complex_spectrum(data, N=number_samples, fs=sample_frequency, 
                          title='Complex Spectrum Plot', units='dBW', fc=0):
    plt_temp = (go.Scatter(x = np.arange(-fs/2, fs/2, fs/N) + fc,
                           y = data, name='Spectrum'))
    return go.FigureWidget(data = plt_temp,
                           layout = {'title': title, 
                                     'xaxis': {
                                         'title': 'Frequency (Hz)',
                                         'autorange': True},
                                     'yaxis': {
                                         'title': units}})


def plot_time(data, n, fs=sample_frequency, 
                      title='Time Plot'):
    plt_temp = (go.Scatter(x = np.arange(0, n/fs, 1/fs),
                              y = np.real(data)))
    return plt_temp
    # return go.FigureWidget(data = plt_temp,
    #                        layout = {'title': title, 
    #                                  'xaxis': {
    #                                      'title': 'Seconds (s)',
    #                                      'autorange' : True},
    #                                  'yaxis': {
    #                                      'title': 'Amplitude (V)'}})

# Functions
# Function to convert integer to binary array
def int_to_binary_array(num, num_bits):
    return np.array(list(format(num, f'0{num_bits}b')), dtype=int)

# Function to convert binary array to integer
def binary_array_to_int(binary_array):
    return int(''.join(map(str, binary_array)), 2)

# Function to generate message with buffer
def _create_buffer(data=np.array([72, 101, 108, 108, 111,  32,  87, 111, 114, 108, 100,  33], dtype=np.uint8), eof=1, padding=0):
        """Create a buffer that is loaded user data. Append the Extended Barker sequence
        to the user data and then pad with zeros
        """
        frame_number = 0
        random_size = 10
        flags = eof
        if data.size == 0:
            raise ValueError('Message size should be greater than 0.')
        msg = np.array(data, dtype=np.uint8)
        # Append Barker and Random Data
        bkr = np.array([0, 0, 63, 112, 28, len(msg) + 5, frame_number, flags, 5, len(msg), padding], dtype=np.uint8)
        rnd = np.array([randint(0, 255) for p in range(0, random_size)], dtype=np.uint8)
        seq = np.append(bkr, msg)
        seq = np.append(rnd, seq)
        pad = np.append(seq, np.zeros(int(np.ceil((len(rnd) + len(bkr) + len(msg))/32) * 32 - (len(rnd) + len(bkr) + len(msg))), dtype=np.uint8))
        buf = allocate(shape=(len(pad),), dtype=np.uint8)
        buf[:] = pad[:]
        return buf
    
def plot_complex_time_multiple(data, data1, n, fs=sample_frequency, 
                      title='Complex Time Plot'):
    plt_re_temp = (go.Scatter(x = np.arange(0, n/fs, 1/fs),
                              y = np.real(data), name='Real'))
    plt_im_temp = (go.Scatter(x = np.arange(0, n/fs, 1/fs),
                              y = np.imag(data), name='Imag'))
    plt_re_temp1 = (go.Scatter(x = np.arange(0, n/fs, 1/fs),
                              y = np.real(data1), name='Real'))
    plt_im_temp1 = (go.Scatter(x = np.arange(0, n/fs, 1/fs),
                              y = np.imag(data1), name='Imag'))
    return go.FigureWidget(data = [[plt_re_temp, plt_im_temp], [plt_re_temp1, plt_im_temp1]],
                           layout = {'title': title, 
                                     'xaxis': {
                                         'title': 'Seconds (s)',
                                         'autorange' : True},
                                     'yaxis': {
                                         'title': 'Amplitude (V)'}})

# Hard code which ADCs to include in the code
included_adcs = [ADC_CHANNEL_A, "", ADC_CHANNEL_C, ADC_CHANNEL_D] 
figs = []

all_fig = make_subplots(specs=[[{"secondary_y": False}]])  # Adjust as necessary
    
    
    


    
# Sample carrier signal
average_phases = [0,0,0,0]
carrier_data = [[],[],[],[]]  # Storage for incoming real data
# for ADC in range(0, len(base.radio.receiver.channel)): # Show all plots
print("MAX VALUES:")

for ADC in range(0, len(base.radio.receiver.channel)): # Show only ADC D
    if(ADC in included_adcs):
        carrier_data[ADC] = base.radio.receiver.channel[ADC].transfer(number_samples)
        time_data = np.arange(0, number_samples/sample_frequency, 1/sample_frequency)
        sampled_signal = np.real(carrier_data[ADC])
        cs_real = CubicSpline(time_data, sampled_signal)
        
        max_data = max(sampled_signal)
        
        print(f"Max for ADC {adc_array[ADC]}: {max_data}")

        # Interpolated data
        dense_t = np.linspace(time_data.min(), time_data.max(), len(time_data) * 10)  # Increase density
        interpolated_signal = cs_real(dense_t)
        
        # Create Plotly figure
        fig = make_subplots(specs=[[{"secondary_y": False}]])  # Adjust as necessary
    
        # Add actual data trace
        fig.add_trace(
        go.Scatter(x=time_data, y=sampled_signal, name=f"Actual Data ADC {adc_array[ADC]}"),
        secondary_y=False,
        )
    
        # Add interpolated data trace
        fig.add_trace(
        go.Scatter(x=dense_t, y=interpolated_signal, name=f"Interpolated Data ADC {adc_array[ADC]}"),
        secondary_y=False,
        )
        # all_fig.add_trace(
        # go.Scatter(x=time_data, y=sampled_signal, name=f"Actual Data ADC {ADC}"),
        # secondary_y=False,
        # )
    
        # Add interpolated data trace
        all_fig.add_trace(
        go.Scatter(x=dense_t, y=interpolated_signal, name=f"Interpolated Data ADC {adc_array[ADC]}"),
        secondary_y=False,
        )
    
        # Update layout
        fig.update_layout(
        title=f"Time Domain Plot of ADC Channel {adc_array[ADC]}",
        xaxis_title="Time (s)",
        yaxis_title="Amplitude",
        )
        
        all_fig.update_layout(
        title=f"Time Domain Plot of all ADC's",
        xaxis_title="Time (s)",
        yaxis_title="Amplitude",
        )
        
        # figs.append(fig)
        
        phase_real = calculate_phase(np.real(carrier_data[ADC]))
        print("Measured Data Phase for ADC " + str(adc_array[ADC]) + ": " + str(round(phase_real,3)))
        

        # Calculate phase for interpolated data
        phase_interpolated = calculate_phase(interpolated_signal)
        print("Interpolated Data Phase for ADC " + str(adc_array[ADC]) + ": " + str(round(phase_interpolated,3)))
        
        average_phases[ADC] = phase_interpolated
        
        # print(carrier_data[ADC])
        # print(interpolated_signal)
    



# print("Measured peak 2 peak amplitude: ? V")
# print("Measured frequency: ? MHz")
# print("Measured period: ? ns")
# print("Phase differences: ????")


figs.append(all_fig)



for figgy in figs:
    figgy.show()
    
    
print()
print("AVERAGE PHASES:")
    
for i in range(0,4):
    adc = ''
    if i == 0:
        adc = 'D'
    if i == 1:
        adc = 'C'
    if i == 2:
        adc = 'B'
    if i == 3:
        adc = 'A'
    print("ADC " + str(adc) + " phase: " + str(round(average_phases[i],3)))
    
    
# APPLY BEAMFORMING WEIGHTS

sample_rate = 1e6
N = 10000 # number of samples to simulate
d = 0.5 # half wavelength spacing
Nr = 4
theta_degrees = 30 # direction of arrival (feel free to change this, it's arbitrary)
theta = theta_degrees / 180 * np.pi # convert to radians

# Create 4 tones to simulate signals being seen by each element
t = np.arange(N)/sample_rate # time vector
shift = 50/4
f_tone = 0.02e6
tx = np.exp(2j * np.pi * f_tone * t)

b_0 = np.exp(-2j * np.pi * d * 0 * np.sin(theta)) # array factor
b_1 = np.exp(-2j * np.pi * d * 1 * np.sin(theta)) # array factor
b_2 = np.exp(-2j * np.pi * d * 2 * np.sin(theta)) # array factor
b_3 = np.exp(-2j * np.pi * d * 3 * np.sin(theta)) # array factor

tx_0 = tx * b_0
tx_1 = tx * b_1
tx_2 = tx * b_2
tx_3 = tx * b_3

beamformed_data = [[],[],[],[]]

beamformed_figs = make_subplots(specs=[[{"secondary_y": False}]])

# DELAY
print(type(b_0))
if theta_degrees >= 0 and theta_degrees <= 90:
    for ADC, data in enumerate(carrier_data):
        if ADC not in included_adcs:
            continue
        if ADC == 0:
            for index, point in enumerate(carrier_data[ADC]):
                beamformed_data[ADC].append(carrier_data[ADC][index] * b_0)
        elif ADC == 1:
            for index, point in enumerate(carrier_data[ADC]):
                beamformed_data[ADC].append(carrier_data[ADC][index])
        elif ADC == 2:
            for index, point in enumerate(carrier_data[ADC]):
                beamformed_data[ADC].append(carrier_data[ADC][index])
        elif ADC == 3:
            for index, point in enumerate(carrier_data[ADC]):
                beamformed_data[ADC].append(carrier_data[ADC][index])
                # Add interpolated data trace

        beamformed_figs.add_trace(
        go.Scatter(x=dense_t, y=np.real(beamformed_data[ADC]), name=f"Beamformed Data ADC {adc_array[ADC]}"),
        secondary_y=False,
        )
        
        if(adc_array[ADC] == 'A'):
            print('debug statement')
            print(ADC)
            print(carrier_data[ADC])
        
        beamformed_figs.update_layout(
        title=f"Time Domain Plot of all Beamformed Data",
        xaxis_title="Time (s)",
        yaxis_title="Amplitude",
        )
elif theta_degrees < 0 and theta_degrees >= -90:
    for ADC, data in enumerate(carrier_data):
        if ADC not in included_adcs:
            continue
        if ADC == 0:
            for index, point in enumerate(carrier_data[ADC]):
                beamformed_data[ADC].append(carrier_data[ADC][index] * b_3)
        elif ADC == 1:
            for index, point in enumerate(carrier_data[ADC]):
                beamformed_data[ADC].append(carrier_data[ADC][index] * b_2)
        elif ADC == 2:
            for index, point in enumerate(carrier_data[ADC]):
                beamformed_data[ADC].append(carrier_data[ADC][index] * b_1)
        elif ADC == 3:
            for index, point in enumerate(carrier_data[ADC]):
                beamformed_data[ADC].append(carrier_data[ADC][index] * b_0)
        beamformed_figs.add_trace(
        go.Scatter(x=dense_t, y=np.real(beamformed_data[ADC]), name=f"Beamformed Data ADC {adc_array[ADC]}"),
        secondary_y=False,
        )
        
        if(adc_array[ADC] == 'A'):
            print('debug statement')
            print(ADC)
            print(carrier_data[ADC])
        
        beamformed_figs.update_layout(
        title=f"Time Domain Plot of all Beamformed Data",
        xaxis_title="Time (s)",
        yaxis_title="Amplitude",
        )
else:
    print("Input angle out of range. Please input an angle between -90 and 90 degrees.")

beamformed_figs.show()
    
summed_data = beamformed_data[0]

for ADC, data in enumerate(beamformed_data):
    if ADC in included_adcs:
        for index in range(len(beamformed_data[ADC])):
            summed_data[index] = summed_data[index] + beamformed_data[ADC][index]
            

summed_figs = make_subplots(specs=[[{"secondary_y": False}]])
summed_figs.add_trace(
        go.Scatter(x=dense_t, y=interpolated_signal, name=f"Summed Beamforming Data"),
        secondary_y=False,
        )
#summed_figs.show()
print(number_samples/sample_frequency)
print(len(summed_data))

time_data = np.arange(0, len(summed_data)/sample_frequency, 1/sample_frequency)

summed_sampled_signal = np.real(summed_data)
cs_real = CubicSpline(time_data, summed_sampled_signal)

# Interpolated data
dense_t = np.linspace(time_data.min(), time_data.max(), len(time_data) * 10)  # Increase density
interpolated_signal = cs_real(dense_t)

# Create Plotly figure
interpolated_summed_figs = make_subplots(specs=[[{"secondary_y": False}]])

# Add actual data trace
interpolated_summed_figs.add_trace(
go.Scatter(x=time_data, y=sampled_signal, name=f"Actual Data Shifted and Summed"),
secondary_y=False,
)

# Add interpolated data trace
interpolated_summed_figs.add_trace(
go.Scatter(x=dense_t, y=interpolated_signal, name=f"Interpolated Data Shifted and Summed"),
secondary_y=False,
)

interpolated_summed_figs.update_layout(
        title=f"Time Domain Plot of Summed and Shifted Beamform Data",
        xaxis_title="Time (s)",
        yaxis_title="Amplitude",
        )

interpolated_summed_figs.show()

print(carrier_data)