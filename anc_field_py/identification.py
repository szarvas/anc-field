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

x = loadtxt('x_noise.dat')
y = loadtxt('y_noise.dat')

paths = [
	'noise_to_error.dat',
	'noise_to_reference_front.dat',
	'noise_to_reference_back.dat',
	'noise_to_reference_left.dat',
	'noise_to_reference_right.dat',
	'noise_to_reference_bottom.dat',
	'noise_to_reference_top.dat'
]

for k in range(0,7):
	h = EstimateIr(x[0::4], y[k,0::4], 3*8e3, 1e-4)
	savetxt(paths[k], h)
	print paths[k]

x = loadtxt('x_actuator.dat')
y = loadtxt('y_actuator.dat')

paths = [
	'actuator_to_error.dat',
	'actuator_to_reference_front.dat',
	'actuator_to_reference_back.dat',
	'actuator_to_reference_left.dat',
	'actuator_to_reference_right.dat',
	'actuator_to_reference_bottom.dat',
	'actuator_to_reference_top.dat'
]

for k in range(0,7):
	h = EstimateIr(x[0::4], y[k,0::4], 3*8e3, 1e-4)
	savetxt(paths[k], h)
	print paths[k]
