clc
clear
close all

eulers = eulergamma;
N = 8; % number of samples to simulate
d = 0.5; % half wavelength spacing
Nr = 4; % number of elements
theta_degrees = 45; % direction of arrival (feel free to change this, it's arbitrary)
theta = theta_degrees / 180 * pi; % convert to radians

% Create 4 tones to simulate signals being seen by each element
f_tone = 1.24e9;
sample_rate = 4915.2e6;
t = 0:(1/sample_rate):(N/sample_rate); % time vector

tx = eulers.^(2j * pi * f_tone .* t);

b_0 = eulers^(-2j * pi * d * 0 * sin(theta)); % array factor
b_1 = eulers^(-2j * pi * d * 1 * sin(theta)); % array factor
b_2 = eulers^(-2j * pi * d * 2 * sin(theta)); % array factor
b_3 = eulers^(-2j * pi * d * 3 * sin(theta)); % array factor

b = [b_3 b_2 b_1 b_0];


tx_0 = tx .* b_0;
tx_1 = tx .* b_1;
tx_2 = tx .* b_2;
tx_3 = tx .* b_3;

tx = [tx_0
      tx_1
      tx_2
      tx_3];

hold on
plot(t, real(tx_0))
plot(t, real(tx_1))
plot(t, real(tx_2))
plot(t, real(tx_3))

title("Original signals")
legend()
hold off

summed_signals = tx_0 + tx_1 + tx_2 + tx_3;
output = b * tx;

% figure
% hold on
% % Plot summed signals before delays
% plot(summed_signals)
% title("Summed Signal Before Delays")
% hold off

figure
plot(real(output))
title("Signals after shifting")
legend()

% % Plot error between received and original signal
% plt.plot(abs((summed_signal/4) - np.asarray(tx_3).squeeze().real[0:200]))
% print("Average Error: ", sum( abs((summed_signal/4) - np.asarray(tx_3).squeeze().real[0:200]) ) /200)
% plt.title("Error")
% plt.show()
