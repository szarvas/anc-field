#About

**anc-field** is a collection of utilities for simulating active noise cancelling in room acoustic environments. All original content is released under the GNU GPL v3 license. Contents of the `anc-field` directory describe a high-performance core written in C++11 and OpenCL 1.1. The binary program can be used through a command line interface, but it is recommended to use the high-level Python wrapper instead.

Room acoustic environments can be described by Kerkythea model files. Wings3D is a good tool to create them. Surface properties are described by impedance filters relating to the materials' acoustic impedance. VLC is used as an online visualization tool through network sockets. This allows for running the anc-field program remotely on a workstation that doesn't need to have local graphical capabilities.

# Getting started

To run the examples you need to fulfill two dependencies
### Python 2.7 32 bit SciPy / Numpi stack
I recommend installing Anaconda that contains everything you might need in a single package.
https://www.continuum.io/downloads

### VLC media player
Actually anything that can play MJPEG over network would be fine. VLC is wired into the `anc_field_py/ancfield.py` file at line 92. If you install VLC with default settings you should be fine, otherwise modify the mentioned line appropriately.

Now you can download a release or build the software for yourself. If you navigate into the example directory with Spyder (part of Anaconda) and open any file, you should be able to run them by hitting F5.

# Troubleshooting
If something goes wrong you may or may not get a helpful error message in Spyder. If you don't you can start the simulation core in interactive mode by running `anc-field/build/anc-field.exe`. The `lsd` command will list the available devices. You may not see any device, or you may not see the kind of device that you asked for in Python, which will make the program crash. In this case get your drivers in order. For a list of interactive commands see the `anc-field/src/main.cpp` file.
