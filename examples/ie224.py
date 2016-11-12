# -*- coding: utf-8 -*-
from __future__ import division

import numpy as np
import matplotlib.pyplot as plt
from scipy import signal, stats

from ancfield import *
from ancutil import *

anc = AncField('cpu', 'models/ie224')

anc.AddSource([4,1.6,1.0], bandnoise([100,2000], 11*32000, 32000))
anc.AddMic([4,1.6,5.3])
anc.AddMic([4,1.6,4.5])
anc.AddMic([4,1.6,6.5])
anc.AddMic([3,1.6,5.5])
anc.AddMic([5,1.6,5.5])
anc.AddMic([4,0.6,5.5])
anc.AddMic([4,2.6,5.5])

anc.Visualize(1.6)
(x,y) = anc.Run(10)
