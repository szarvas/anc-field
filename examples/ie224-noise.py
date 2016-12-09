# -*- coding: utf-8 -*-
from __future__ import division

import numpy as np
import matplotlib.pyplot as plt
from scipy import signal, stats

import sys
sys.path.append('..')

from anc_field_py.ancfield import *
from anc_field_py.ancutil import *

# We define microphone handles
microphones = [
    ('error', [4,1.6,5.3]),
    ('reference_front', [4,1.6,4.5]),
    ('reference_back', [4,1.6,6.5]),
    ('reference_left', [3,1.6,5.5]),
    ('reference_right', [5,1.6,5.5]),
    ('reference_bottom', [4,0.6,5.5]),
    ('reference_top', [4,2.6,5.5])
]

noise_pos = [4,1.6,1.0]
actuator_pos = [4,1.6,5.5]

sim_name = 'ie224-noise'

def add_microphones(ancObject):
    for m in microphones:
        ancObject.AddMic(m[1])
    
    return ancObject


# =========================================================================
# SIMULATION 1
# Calculating noise to microphone paths
# =========================================================================
#
# Trying to run this simulation on CPU failed on an i7-3770, compiling the
# lrs_1.cl file fails. It maybe because the scene's size is too large for
# the CPU. Compiling it for the built in integrated GPU worked though.
# 
# We create a simulation and immediately add microphones to it
anc = add_microphones(AncField('gpu', 'models/ie224'))

# noise_source
lower_bound = 100
upper_bound = 2000
fs = 32000
noise = bandnoise([lower_bound,upper_bound], 11*fs, fs)
anc.AddSource(noise_pos, noise)

anc.Visualize(1.6)
(x,y_noise) = anc.Run(10)

# Saving the impulse responses
for i in range(0, y_noise.shape[0]):
    h = EstimateIr(x[0,:], y_noise[i,:], fs*2)
    np.savetxt(sim_name + '-results/' + 'noise-to-' + microphones[i][0] + '.dat', h)
    
    # GENERATING IMAGE FOR THE REPORT
    fig, ax = plt.subplots()
    ax.plot(h)
    plt.title(sim_name + '-noise-to-' + microphones[i][0])
    fig.savefig(sim_name + '-results/' + 'noise-to-' + microphones[i][0] + '.png')



    
    
# =========================================================================
# SIMULATION 2
# Calculating actuator to microphone paths
# =========================================================================
#
# We create a simulation and immediately add microphones to it
anc = add_microphones(AncField('gpu', 'models/ie224'))

# actuator
anc.AddSource(actuator_pos, noise)

anc.Visualize(1.6)
(x,y_actuator) = anc.Run(10)

# Saving the impulse responses
for i in range(0, y_actuator.shape[0]):
    h = EstimateIr(x[0,:], y_actuator[i,:], fs*2)
    np.savetxt(sim_name + '-results/' + 'actuator-to-' + microphones[i][0] + '.dat', h)

    # GENERATING IMAGE FOR THE REPORT
    fig, ax = plt.subplots()
    ax.plot(h)
    plt.title(sim_name + '-actuator-to-' + microphones[i][0])
    fig.savefig(sim_name + '-results/' + 'actuator-to-' + microphones[i][0] + '.png')
