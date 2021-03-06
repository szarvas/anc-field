function Hd = noise_filter(Fpass, Fstop, Fs)
%NOISE_FILTER Returns a discrete-time filter object.

%
% MATLAB Code
% Generated by MATLAB(R) 7.11 and the Signal Processing Toolbox 6.14.
%
% Generated on: 04-Dec-2013 15:49:57
%

% Equiripple Lowpass filter designed using the FIRPM function.

% All frequency values are in Hz.
% Fs = 64000;  % Sampling Frequency

% Fpass = 4000;            % Passband Frequency
% Fstop = 4200;            % Stopband Frequency
Dpass = 0.028774368332;  % Passband Ripple
Dstop = 0.0001;          % Stopband Attenuation
dens  = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd = dfilt.dffir(b);

% [EOF]
