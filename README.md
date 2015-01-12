#About

**anc-field** is a collection of utilities for simulating active noise cancelling in room acoustic environments. All original content is released under the GNU GPL v3 license.

Contents of the `anc-field` directory describe a high-performance core written in C++11 and OpenCL 1.1. The binary program can be used through a command line interface, but it is recommended to use the high-level Python wrapper instead.

Room acoustic environments can be described by Kerkythea model files. Wings3D is a good tool to create them. Surface properties are described by impedance filters relating to the materials' acoustic impedance. VLC is used as an online visualization tool through network sockets. This allows for running the anc-field program remotely on a workstation that doesn't need to have local graphical capabilities.

Contents of the `wrapper` directory contain two important modules. The `ancfield` module has a wrapper class for the binary `anc-field` program for easier usage.

Contents of the `impulse-anc-matlab` directory contains Matlab classes allowing the simulation of MIMO ANC systems based on the impulse responses obtained from the acoustic simulation using the `wrapper/ancutil` functions. These classes will eventually be ported to Python.
