function b = da_filter()
%DA_FILTER Returns a discrete-time filter object.

%
% MATLAB Code
% Generated by MATLAB(R) 7.11 and the Signal Processing Toolbox 6.14.
%
% Generated on: 04-Dec-2013 15:42:37
%

% Generalized REMEZ FIR Lowpass filter designed using the FIRGR function.

% All frequency values are in Hz.
Fs = 32000;  % Sampling Frequency

Fpass = 2000;            % Passband Frequency
Fstop = 3000;            % Stopband Frequency
Dpass = 0.057501127785;  % Passband Ripple
Dstop = 0.0001;          % Stopband Attenuation
dens  = 20;              % Density Factor

% Calculate the coefficients using the FIRGR function.
b  = firgr('minorder', [0 Fpass Fstop Fs/2]/(Fs/2), [1 1 0 0], [Dpass ...
           Dstop], {dens});

% [EOF]
