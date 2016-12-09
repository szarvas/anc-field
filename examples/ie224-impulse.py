# -*- coding: utf-8 -*-
from __future__ import division

import numpy as np
import matplotlib.pyplot as plt
from scipy import signal, stats

import sys
sys.path.append('..')

from anc_field_py.ancfield import *
from anc_field_py.ancutil import *

def add_microphones(ancObject):
    # error_mic
    ancObject.AddMic([4,1.6,5.3])
    
    # reference_front
    ancObject.AddMic([4,1.6,4.5])
    
    # reference_back
    ancObject.AddMic([4,1.6,6.5])
    
    # reference_left
    ancObject.AddMic([3,1.6,5.5])
    
    # reference_right
    ancObject.AddMic([5,1.6,5.5])
    
    # reference_bottom
    ancObject.AddMic([4,0.6,5.5])
    
    # reference_top
    ancObject.AddMic([4,2.6,5.5])
    
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
anc.AddSource([4,1.6,1.0], 5*impulse(2000, 6*32000, 32000))

anc.Visualize(1.6)
(x,y_noise) = anc.Run(4)

# Saving the impulse responses
np.savetxt('ie224-noise-to-error.dat', y_noise[0,:])
np.savetxt('ie224-noise-to-reference_front.dat', y_noise[1,:])
np.savetxt('ie224-noise-to-reference_back.dat', y_noise[2,:])
np.savetxt('ie224-noise-to-reference_left.dat', y_noise[3,:])
np.savetxt('ie224-noise-to-reference_right.dat', y_noise[4,:])
np.savetxt('ie224-noise-to-reference_bottom.dat', y_noise[5,:])
np.savetxt('ie224-noise-to-reference_top.dat', y_noise[6,:])





# =========================================================================
# SIMULATION 2
# Calculating actuator to microphone paths
# =========================================================================
#
# We create a simulation and immediately add microphones to it
anc = add_microphones(AncField('gpu', 'models/ie224'))

# actuator
anc.AddSource([4,1.6,5.5], 5*impulse(2000, 6*32000, 32000))

anc.Visualize(1.6)
(x,y_actuator) = anc.Run(4)

# Saving the impulse responses
np.savetxt('ie224-actuator-to-error.dat', y_actuator[0,:])
np.savetxt('ie224-actuator-to-reference_front.dat', y_actuator[1,:])
np.savetxt('ie224-actuator-to-reference_back.dat', y_actuator[2,:])
np.savetxt('ie224-actuator-to-reference_left.dat', y_actuator[3,:])
np.savetxt('ie224-actuator-to-reference_right.dat', y_actuator[4,:])
np.savetxt('ie224-actuator-to-reference_bottom.dat', y_actuator[5,:])
np.savetxt('ie224-actuator-to-reference_top.dat', y_actuator[6,:])




# =========================================================================
# GENERATING IMAGES FOR THE REPORT
# Calculating actuator to microphone paths
# =========================================================================
#
# Saving figures for the field simulation report
fig, ax = plt.subplots()
ax.plot(y_noise[0,:])
plt.title('ie224-noise-to-error')
fig.savefig('ie224-noise-to-error.png')

fig, ax = plt.subplots()
ax.plot(y_noise[1,:])
plt.title('ie224-noise-to-reference_front')
fig.savefig('ie224-noise-to-reference_front.png')

fig, ax = plt.subplots()
ax.plot(y_noise[2,:])
plt.title('ie224-noise-to-reference_back')
fig.savefig('ie224-noise-to-reference_back.png')

fig, ax = plt.subplots()
ax.plot(y_noise[3,:])
plt.title('ie224-noise-to-reference_left')
fig.savefig('ie224-noise-to-reference_left.png')

fig, ax = plt.subplots()
ax.plot(y_noise[4,:])
plt.title('ie224-noise-to-reference_right')
fig.savefig('ie224-noise-to-reference_right.png')

fig, ax = plt.subplots()
ax.plot(y_noise[5,:])
plt.title('ie224-noise-to-reference_bottom')
fig.savefig('ie224-noise-to-reference_bottom.png')

fig, ax = plt.subplots()
ax.plot(y_noise[6,:])
plt.title('ie224-noise-to-reference_top')
fig.savefig('ie224-noise-to-reference_top.png')


# Saving figures for the field simulation report
fig, ax = plt.subplots()
ax.plot(y_actuator[0,:])
plt.title('ie224-actuator-to-error')
fig.savefig('ie224-actuator-to-error.png')

fig, ax = plt.subplots()
ax.plot(y_actuator[1,:])
plt.title('ie224-actuator-to-reference_front')
fig.savefig('ie224-actuator-to-reference_front.png')

fig, ax = plt.subplots()
ax.plot(y_actuator[2,:])
plt.title('ie224-actuator-to-reference_back')
fig.savefig('ie224-actuator-to-reference_back.png')

fig, ax = plt.subplots()
ax.plot(y_actuator[3,:])
plt.title('ie224-actuator-to-reference_left')
fig.savefig('ie224-actuator-to-reference_left.png')

fig, ax = plt.subplots()
ax.plot(y_actuator[4,:])
plt.title('ie224-actuator-to-reference_right')
fig.savefig('ie224-actuator-to-reference_right.png')

fig, ax = plt.subplots()
ax.plot(y_actuator[5,:])
plt.title('ie224-actuator-to-reference_bottom')
fig.savefig('ie224-actuator-to-reference_bottom.png')

fig, ax = plt.subplots()
ax.plot(y_actuator[6,:])
plt.title('ie224-actuator-to-reference_top')
fig.savefig('ie224-actuator-to-reference_top.png')

