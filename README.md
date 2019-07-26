# The Orocos Toolchain

The Open RObot COntrol Software ([Orocos](http://www.orocos.org/)) Toolchain is a bundle of multiple packages, which need to be build and installed separately.

- [Orocos Real-Time Toolkit (rtt)](https://github.com/orocos-toolchain/rtt) - a component framework that allows us to write real-time components in C++
- [Orocos Log4cpp (log4cpp)](https://github.com/orocos-toolchain/log4cpp) -
  a patched version of the [Log4cpp](http://log4cpp.sourceforge.net/) library for flexible logging to files, syslog, IDSA and other destinations
- [Orocos Component Library (ocl)](https://github.com/orocos-toolchain/ocl) - the necessary components to start an application and interact with it at run-time

Futhermore the Orocos Toolchain comes with [oroGen](http://www.rock-robotics.org/stable/documentation/orogen/) and some of its dependencies,
a specification language and code generator for the Orocos Realtime Toolkit. Also check the installation instructions of the
[Rock - the Robot Construction Kit](http://www.rock-robotics.org/stable/index.html) project for further details.

You might also want to have a look at the following sister projects, which are out of the scope of this manual:
- [Orocos Kinematics Dynamics Library (KDL)](http://www.orocos.org/kdl) - an application independent framework for modeling and computation of kinematic chains
- [Orocos Bayesian Filtering Library (BFL)](http://www.orocos.org/bfl) - an application independent framework for inference in Dynamic Bayesian Networks, i.e., recursive information processing and estimation algorithms based on Bayes' rule
- [Reduced Finite State Machine (rFSM)](https://orocos.github.io/rFSM/README.html) - a small and powerful statechart implementation in Lua

## Documentation

The latest documentation and API reference is currently available at https://orocos-toolchain.github.io/.

## Get Started?

### Install binary packages

The Orocos project provides binary packages as part of the [ROS distribution](http://www.ros.org) for various platforms.
Check and follow the [ROS installation instructions](http://wiki.ros.org/ROS/Installation), then run
```sh
sudo apt-get install ros-${ROS_DISTRO}-orocos-toolchain
```

to install the Orocos Toolchain packages.

As a ROS user, you might also be interested in the [rtt_ros_integration](http://wiki.ros.org/rtt_ros_integration) project:
```sh
sudo apt-get install ros-${ROS_DISTRO}-rtt-ros-integration
```

### Build the toolchain from source

First, clone this repository and its submodules with the command
```sh
git clone https://github.com/orocos-toolchain/orocos_toolchain.git --recursive
```

If you already have a working copy, make sure that all submodules are up-to-date:
```sh
git submodule update --init --recursive
```

The next step is to configure the toolchain according to your needs:
```sh
./configure --prefix=<installation prefix> [<options>]
```

```sh
Usage: ./configure [<options>] [<additional cmake arguments>]

Available options:

  --prefix <prefix>        Installation prefix (-DCMAKE_INSTALL_PREFIX)

  --{en|dis}able-corba     Enable/Disable CORBA transport plugin (-DENABLE_CORBA)
  --omniorb                Select CORBA implementation OmniORB
  --tao                    Select CORBA implementation TAO
```

`configure` is nothing else than a simple wrapper around [CMake](https://cmake.org/).
Check `./configure --help` for the latest available options.

Last but not least, build the toolchain by running
```sh
make install [-j<parallel jobs>]
```

