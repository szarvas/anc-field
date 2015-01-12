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

from numpy import *
from ancutil import *

for num_noise in range(0,4):

	x = loadtxt('x_noise_'+str(num_noise)+'.dat')
	y = loadtxt('y_noise_'+str(num_noise)+'.dat')

	paths = [
		'anechoic3/noise_'+str(num_noise)+'_to_error.dat',
		'anechoic3/noise_'+str(num_noise)+'_to_reference_front.dat',
		'anechoic3/noise_'+str(num_noise)+'_to_reference_back.dat',
		'anechoic3/noise_'+str(num_noise)+'_to_reference_left.dat',
		'anechoic3/noise_'+str(num_noise)+'_to_reference_right.dat'
	]

	for k in range(13,17):
		h = EstimateIr(x[0::4], y[k,0::4], 1*8e3, 1e-4)
		savetxt(paths[k-12], h)
		print paths[k-12]

x = loadtxt('x_actuator.dat')
y = loadtxt('y_actuator.dat')

paths = [
	'anechoic3/actuator_to_error.dat',
	'anechoic3/actuator_to_reference_front.dat',
	'anechoic3/actuator_to_reference_back.dat',
	'anechoic3/actuator_to_reference_left.dat',
	'anechoic3/actuator_to_reference_right.dat'
]

for k in range(13,17):
	h = EstimateIr(x[0::4], y[k,0::4], 1*8e3, 1e-4)
	savetxt(paths[k-12], h)
	print paths[k-12]
