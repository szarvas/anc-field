function x = bandnoise( bw, a, fs, len )
%BANDNOISE Returns a sequence of bandlimited white noise
%   X = BANDNOISE(BW, LENGTH, FS) Returns a Gaussian noise
%   sequence with a bandwidth of BW, element number of LENGTH
%   and sampling frequency of fs.

s = RandStream('mt19937ar','Seed', sum(100*clock));
z = 2*s.rand(1, len+1000)-1;

fstop = bw+(200/64000*fs);
[Hd] = noise_filter(bw, fstop, fs);

x = filter(Hd, z);
x = x(501:end-500);
x = x/max(abs(x));
pi_series = [0:pi/200:pi];
x(1:200) = x(1:200).*abs(sin(-pi/2+pi_series(1:200))+1)/2;

end
