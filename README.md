# The OROCOS Toolchain

The Open RObot COntrol Software ([Orocos](http://www.orocos.org/)) Toolchain is a bundle of multiple packages, which need to be build and installed separately.

- [Orocos Real-Time Toolkit (rtt)](https://github.com/orocos-toolchain/rtt) - a component framework that allows us to write real-time components in C++
- [Orocos Log4cpp (log4cpp)](https://github.com/orocos-toolchain/log4cpp) -
  a patched version of the [Log4cpp](http://log4cpp.sourceforge.net/) library for flexible logging to files, syslog, IDSA and other destinations
- [Orocos Component Library (ocl)](https://github.com/orocos-toolchain/ocl) - the necessary components to start an application and interact with it at run-time

Until version 2.8 [orogen](http://www.rock-robotics.org/stable/documentation/orogen/) and [typegen](http://www.rock-robotics.org/stable/documentation/orogen/), tools to generate ready-to-compile-and-run code from existing headers or component description files based on the Ruby language, have been an integral part of the Orocos Toolchain. For later versions we refer to the installation instructions of the [Rock - the Robot Construction Kit](http://www.rock-robotics.org/stable/index.html) project.

You might also want to have a look at the following sister projects, which are out of the scope of this manual:
- [Orocos Kinematics Dynamics Library (KDL)](http://www.orocos.org/kdl) - an application independent framework for modeling and computation of kinematic chains
- [Orocos Bayesian Filtering Library (BFL)](http://www.orocos.org/bfl) - an application independent framework for inference in Dynamic Bayesian Networks, i.e., recursive information processing and estimation algorithms based on Bayes' rule
- [Reduced Finite State Machine (rFSM)](https://orocos.github.io/rFSM/README.html) - a small and powerful statechart implementation in Lua

## Get Started?
Check out [INSTALL.md](INSTALL.md).
