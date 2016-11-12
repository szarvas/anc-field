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
    
    # reference top
    ancObject.AddMic([4,2.6,5.5])
    
    return ancObject

# We create a simulation and immeatealy add microphones to it
anc = add_microphones(AncField('cpu', 'models/ie224'))
    
# noise_source
anc.AddSource([4,1.6,1.0], bandnoise([100,2000], 11*32000, 32000))

anc.Visualize(1.6)
(x,y) = anc.Run(10)

#h = EstimateIr(x[0,:], y, anc.fs)
#np.savetxt('h_'+sim+'.dat', h)
#h = EstimateIr(x[0::4], y[6,0::4], 3*8e3, 1e-4)
#savetxt('noise_to_reference_bottom.dat', h)