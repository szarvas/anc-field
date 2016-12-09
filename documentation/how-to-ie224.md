This tutorial gives you an overview about carrying out a complete simulation. This includes a field simulation that will result in determining the impulse responses between all points of interest of a 1x1 ANC system with 6 reference microphones.

The steps are the following. Since the repo contains the generated impulse responses you can skip step 2 and go straight to step 3 if you have Matlab.

1. Make sure you have the prerequisites to run the simulation. The field simulation requires **Anaconda 2.7 32 bit** https://www.continuum.io/downloads and **VLC media player**. The noise cancelling simulation requires **Matlab 2010**.
2. Open [examples/ie224-noise.py](../examples/ie224-noise.py) in Spyder (it comes with Anaconda). Press F5. This will generate all the paths and save them in the [examples/ie224-noise-results](../examples/ie224-noise-results) directory. You can view a report of this in [examples/report.md](../examples/report.md).
3. Open [impulse-anc-matlab/ie224.m](../impulse-anc-matlab/ie224.m) and hit F5. This will reference the files generated in the previous step, simulate an ANC system and display the achieved suppression.

You should get a suppression of roughly 20 dB.

# Tips
The field simulation takes about 10 minutes on a GPU, but identifying the impulse responses takes hours. You can skip this part, since I've already run the simulation and put the results into the package.

You can also skip the inverse estimation of the secondary path by commenting and uncommenting the appropriate lines in [impulse-anc-matlab/ie224.m](../impulse-anc-matlab/ie224.m), because I included that result as well.
