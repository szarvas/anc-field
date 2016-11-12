# -*- coding: utf-8 -*-
from __future__ import division

import numpy as np
import matplotlib.pyplot as plt
from scipy import signal, stats

import sys
sys.path.append('..')

from anc_field_py.ancfield import *
from anc_field_py.ancutil import *

# Run a simulation using the CPU and the geometrical data
# in the `models/dsp` folder. The simulation expects that
# this folder will contain a Kerkythea model named `model.xml`
# and the `material_a.dat`, `material_b.dat` files pertaining
# to the materials referenced in it.
anc = AncField('cpu', 'models/dsp')

# Place a microphone at position x=3, y=1, z=1 in meters.
# The acoustic pressure at this point will be recorder, and
# the recorded data vector will be part of the `y` matrix
# returned by the Run function
anc.AddMic([3,1,3])

# We place a source. The first argument is the position, the
# second is a `numpy.array` object containing the samples of the
# sound.
lower_bound = 100
upper_bound = 2000
fs = 32000
anc.AddSource([4.5,1,3.6], bandnoise([lower_bound,upper_bound], 11*fs, fs))

# We want to see visualization throughout the simulation along
# the XY plane at a height of z=1 meter.
anc.Visualize(1)

# Run the simulation for 10 seconds. The rows of `x` contain the
# source samples in the order of calling the AddMic function
# The rows of `y` contain the recorded sound pressure at the
# positions set by AddSource.
(x,y) = anc.Run(10)

# Let's estimate the impulse response between the first source and
# the first Mic recording. Arguments are 1) input vector, 2) output
# output vector, and the 3) estimation order.
h = EstimateIr(x[0,:], y, anc.fs)

# Let's save the impulse response so that we can use it later
np.savetxt('dsp_ir.dat', h)

# Let's take a look at the IR
# It should look something like `dsp_ir_plot.png`
plt.plot(h)
plt.show()
