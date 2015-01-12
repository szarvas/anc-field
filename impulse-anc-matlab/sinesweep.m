function x = sinesweep(f, a, fs, len)
	t = 0:len-1;
    df = (f/2-200)/(len-1);
    f = 200:df:f/2;
	x = a*sin(2*pi/fs*(f.*t));
end