# -*- coding: utf-8 -*-
from __future__ import division

import numpy as np
import matplotlib.pyplot as plt
from scipy import signal, stats

import sys
sys.path.append('..')

from anc_field_py.ancfield import *
from anc_field_py.ancutil import *

anc = AncField('gpu', 'models/room_modes')

anc.AddSource([1.48,0.48,0.48], 10*impulse(2000, 6*32000, 32000))
anc.AddMic([0.5,0.2,0.3])
anc.AddMic([0.4,0.4,0.4])
anc.AddMic([1.5,1.2,3])
anc.AddMic([1.5,1.2,3])
anc.AddMic([2.2,1.7,4])

anc.Visualize(0.12)

(x,y) = anc.Run(1.5)

savetxt('modes_x.dat', x)
savetxt('modes_y.dat', y)
