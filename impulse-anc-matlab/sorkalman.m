clc;
clear all;
close all;

a = [14 10 6 8 10];
q = (100 - a) / 100;
r = sqrt(q);
h = [0.92 0.95 0.96 0.96 0.96];
f = [125  250  500  1000  2000];

f = f / 16e3;
f = f * pi;

[b,a] = invfreqz(r,f,1,1);

h = tf(b,a,-1);

sor = [1 zeros(1,9999)];

bor = filter(b,a,sor);

efte = abs(fft(bor));
freki = [0:4999] * 32e3/5000;

otszaz = ceil(10000/32e3*500);
b = b / (efte(otszaz)/r(3));

sor = [1 zeros(1,9999)];

bor = filter(b,a,sor);

efte = abs(fft(bor));
freki = [0:4999] * 32e3/5000;


plot(freki, efte(1:5000))

% bode(h)