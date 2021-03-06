# -*- coding: utf-8 -*-
"""
Copyright 2014 Attila Szarvas

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

from __future__ import division

import numpy as np
from scipy import signal

def EstimateIr(input, output, N, mu=1e-4):
	W = np.zeros(N)

	for m in range(0,16):
		steps = min(np.size(input, 0), np.size(output, 0))
		x_buf = np.zeros(N)

		for k in range(0, steps):
			x_buf = np.concatenate( (np.array([input[k]]), x_buf[0:-1]) )
			y_est = np.dot(W, x_buf)
			e = output[k] - y_est
			W = W + 2*mu*e*x_buf

	return W

def bandnoise(bands, length, fs):
	z = 2*np.random.rand(length)-1;
	if len(bands) > 1 and bands[0] != 0:
		b = signal.firwin(10000, [c/(fs/2) for c in bands], pass_zero=False)
	elif len(bands) > 1:
		b = GetLpFir(bands[1], 100, fs)
	x = signal.lfilter(b, 1, z);

	return x

def impulse(bw, length, fs):
	x = np.zeros(length)
	x[1] = 1
	b = GetLpFir(bw, 100, fs)
	x = signal.lfilter(b, 1, x)

	return x

def GetLpFir(cutoff, transition, fs):
	#------------------------------------------------
	# Create a FIR filter and apply it to x.
	#------------------------------------------------

	# The Nyquist rate of the signal.
	nyq_rate = fs / 2.0

	# The desired width of the transition from pass to stop,
	# relative to the Nyquist rate.  We'll design the filter
	# with a 5 Hz transition width.
	width = transition/nyq_rate

	# The desired attenuation in the stop band, in dB.
	ripple_db = 80.0

	# Compute the order and Kaiser parameter for the FIR filter.
	N, beta = signal.kaiserord(ripple_db, width)

	# Use firwin with a Kaiser window to create a lowpass FIR filter.
	taps = signal.firwin(N, cutoff/nyq_rate, window=('kaiser', beta))

	return taps
