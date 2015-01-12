function x = sinesource(f, a, fs, len)
	t = [0:len-1];
	x = sin(2*pi/fs*f*t);
    pi_series = [0:pi/200:pi];
% 	x(1:200) = x(1:200).*abs(sin(-pi/2+pi_series(1:200))+1)/2;
	x = a*x;
end