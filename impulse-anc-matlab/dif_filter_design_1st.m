clc;
clear all;
close all;

fs = 32e3;
% 
% theta = 500 * 2*pi / fs;
% m = 0.9;
% 
% p1 = m*exp(j*theta);
% p2 = m*exp(-j*theta);
% 
% k = 0.02;
% 
% sys = zpk([], [p1 p2], k, -1);
% % pzmap(sys);
% 
% [b a] = tfdata(sys);
% y = filter(cell2mat(b),cell2mat(a),bandnoise(10000, 1.0, 64e3, 256e3));
% psd(spectrum.welch('Hamming',2048), y,'Fs',64000)

N = 100;
att = 1;

% butorlap / fal
% F = [0  125 250 500 1000 2000 4000 fs/2];
% D = [14 14  10  6   8    10   10   2];
% D = [6   6  6   6   8    10   10   2];

% uveg
F = [0  125 250 500 1000 2000 4000 fs/2];
D = [8  8   4   3   3    2    2    2];

% parketta, fodem, festett beton
% F = [0  125 250 500 1000 2000 4000 fs/2];
% D = [4  4   4   5   6    6    6    4];

% % ajto
% F = [0  125 250 500 1000 2000 4000 fs/2];
% D = [14 14  10  8   8    8    8   2];

F = F / (fs/2);
A = sqrt( (100 - D) / 100 );

h = fir2(N,F,A);

% Plotting the filter
fftlength = 10000;
frequencies = (0:fftlength-1)*(fs/fftlength);
K = (abs(fft(h,10000)));
plot(frequencies(1:1600), K(1:1600));
xlabel('f [Hz]');
ylabel('K(f) [dB]');

[b a] = stmcb(h, 1, 1);
y = bode(tf(b,a,-1));
% b = b / (y(1)/A(5));
b = b / (y(1)/sqrt(0.91));
figure; bode(tf(b,a,-1));

num = b + a;
den = -b + a;

% pzmap(tf(num, den, -1))
% psd(spectrum.welch('Hamming',2048), filter(b,a,bandnoise(10000, 1.0, 64e3, 64e4)), 'Fs', fs);