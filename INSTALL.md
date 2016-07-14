# The OROCOS Toolchain Installation Guide

This document explains how the [Orocos](http://www.orocos.org/) toolchain can be installed and configured.

## Table of Contents
<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Table of Contents](#table-of-contents)
- [Introduction](#introduction)
	- [Supported platforms (targets)](#supported-platforms-targets)
	- [The versioning scheme](#the-versioning-scheme)
	- [Dependencies on other libraries](#dependencies-on-other-libraries)
- [Binary packages](#binary-packages)
	- [Ubuntu and Debian](#ubuntu-and-debian)
- [Install from source](#install-from-source)
	- [Build tools and dependencies](#build-tools-and-dependencies)
		- [Debian/Ubuntu](#debianubuntu)
		- [Other Linux distributions](#other-linux-distributions)
		- [MacOS X](#macos-x)
		- [Windows](#windows)
	- [Quick start](#quick-start)
	- [Download the sources](#download-the-sources)
		- [Download source archive](#download-source-archive)
		- [Clone from GitHub](#clone-from-github)
	- [3. Build and Install](#3-build-and-install)
- [Getting Started](#getting-started)
- [Cross Compiling Orocos](#cross-compiling-orocos)

<!-- /TOC -->

## Introduction

This sections explains the supported Orocos targets and the Orocos versioning scheme.

### Supported platforms (targets)

Orocos was designed with portability in mind. Currently, we support RTAI/LXRT (http://www.rtai.org), GNU/Linux userspace, Xenomai (http://www.xenomai.org), Mac OS X (http://www.apple.com) and native Windows using Microsoft Visual Studio. So, you can first write your software as a normal Linux/Mac OS X program, using the framework for testing and debugging purposes in plain userspace (Linux/Mac OS X) and recompile later to a real-time target or MS Windows.

### The versioning scheme

A particular version is represented by three numbers separated by dots. For example:

2.8.1 : Release 2, Feature update 8, bug-fix revision 1.

### Dependencies on other libraries

Before you install Orocos, verify that you have the following software installed on your platform:

| Program / Library               | Minimum Version               | Description                                                                                                                                                                                                                                                                            |
|---------------------------------|-------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| CMake                           | 2.8.3 (all platforms)         | See resources on cmake.org for pre-compiled packages in case your distribution does not support this version                                                                                                                                                                           |
| Boost C++ Library               | 1.33.0 (1.40.0 recommended!)  | Boost.org from version 1.33.0 on has a very efficient (time/space) lock-free smart pointer implementation which is used by Orocos. 1.36.0 has boost::intrusive which we require on Windows with MSVS. 1.40.0 has a shared_ptr implementation we require when building Service objects. |
| Boost C++ Test Library          | 1.33.0 (During build only)    | Boost.org test library ('unit_test_framework') is required if you build the RTT from source and ENABLE_TESTS=ON (default). The RTT libraries don't depend on this library, it is only used for building our unit tests.                                                                |
| Boost C++ Thread Library        | 1.33.0 (Mac OS-X only)        | Boost.org thread library is required on Mac OS-X.                                                                                                                                                                                                                                      |
| Boost C++ Serialization Library | 1.37.0                        | Boost.org serialization library is required for the type system and the MQueue transport.                                                                                                                                                                                              |
| GNU gcc / g++ Compilers         | 3.4.0 (Linux/Cygwin/Mac OS X) | gcc.gnu.org Orocos builds with the GCC 4.x series as well.                                                                                                                                                                                                                             |
| MSVS Compilers                  | 2005                          | One can download the MS VisualStudio 2008 Express edition for free.                                                                                                                                                                                                                    |
| Xerces C++ Parser               | 2.1 (Optional)                | Xerces website Versions 2.1 until 3.1 are known to work. If not found, an internal XML parser is used.                                                                                                                                                                                 |
| ACE & TAO                       | TAO 1.3 (Optional)            | ACE & TAO website When you start your components in a networked environment, TAO can be used to set up communication between components. CORBA is used as a 'background' transport and is hidden for normal users.                                                                     |
| Omniorb                         | 4 (Optional)                  | Omniorb website Omniorb is more robust and faster than TAO, but has less features. CORBA is used as a 'background' transport and is hidden for normal users.                                                                                                                           |

All these packages are provided by most Linux distributions. In Mac OS X, you can install them easily using fink or macports. Take also a look on the Orocos.org RTT download page for the latest information.

## Binary packages

### Ubuntu and Debian

The [Robot Operating System (ROS)](http://www.ros.org/) project provides binary packages for Ubuntu and Debian Jessie. See [REP 3 - Target Platforms](http://www.ros.org/reps/rep-0003.html) for a list of supported platforms. The dependencies of the Orocos core packages to other ROS packages are minimal. This is the recommended way to get started with the toolchain for Ubuntu and Debian users.

Check out the [ROS Installation instructions](http://wiki.ros.org/ROS/Installation) for detailed instructions on how to install a ROS base system. Afterwards, the Orocos Toolchain can be installed with the command

```
sudo apt-get install ros-<distro>-orocos-toolchain
```

## Install from source

### Build tools and dependencies

#### Debian/Ubuntu

Most dependencies mentioned above can be installed using the APT package management system:

```
sudo apt-get install build-essential git cmake libboost-all-dev libxml-xpath-perl
```

*Optional:* In case you want to build RTT with CORBA support, you also need to install the OmniORB (recommended) or TAO development packages:

```
sudo apt-get install omniorb omniidl omniorb-idl omniorb-nameserver libomniorb4-dev
```

#### Other Linux distributions
*TODO*

#### MacOS X
*TODO*

#### Windows
*TODO*

### Quick start

The [orocos_toolchain](https://github.com/orocos-toolchain/orocos_toolchain) repository contains a shell script which implements all of the following steps and is the recommended way to install the Orocos toolchain from source:

For Linux:
```
mkdir -p ~/orocos-toolchain
cd ~/orocos-toolchain
wget https://raw.githubusercontent.com/orocos-toolchain/orocos_toolchain/master/install.sh
./install.sh --help
```

If you want to download or clone the sources manually and have full control over the build process, feel free to go o

### Download the sources

#### Download source archive

The latest released version of the toolchain can be downloaded from here:
http://www.orocos.org/orocos/toolchain

Extract the archive into a source directory, e.g. `~/orocos-toolchain`:
```
mkdir -p ~/orocos-toolchain && cd ~/orocos-toolchain
wget http://www.orocos.org/stable/toolchain/v2.x.x/orocos-toolchain-2.x.x-src.tar.bz2
tar xvjf orocos-toolchain-2.x.x-src.tar.bz2
cd orocos-toolchain-*
```

Note that the archive files provided by GitHub at https://github.com/orocos-toolchain/orocos_toolchain/releases will not work as the repository contains submodules, which are unfortunately not included in the files.

#### Clone from GitHub

If you want to use the latest development version or actively contribute to Orocos, it is recommended to clone the toolchain directly from GitHub:

```
mkdir -p ~/orocos-toolchain && cd ~/orocos-toolchain
git clone --recursive https://github.com/orocos-toolchain/orocos_toolchain.git
cd orocos-toolchain
```

In order to select a specific major and minor version of the toolchain, you can specify the branch to be cloned explicitly with the `-b` option, e.g.:

```
mkdir -p ~/orocos-toolchain && cd ~/orocos-toolchain
git clone --recursive https://github.com/orocos-toolchain/orocos_toolchain.git -b toolchain-2.9
cd orocos-toolchain
```

The `--recursive` argument is required because the toolchain GIT repository uses submodules to manage the links to the individual source repositories.

### 3. Build and Install

All toolchain packages rely on cmake as the underlying build tool, but every package has to be configured, build and installed in isolation.
Advanced users can invoke cmake and make directly or use [catkin](http://wiki.ros.org/catkin) or [catkin_tools](https://catkin-tools.readthedocs.io/en/latest/) as a build tool.
Otherwise it is recommended to use the `install.sh` script provided in the toolchain repository, which iterates over all toolchain packages in the right order and invokes cmake, make and make install within the `build/<package>` directory for each of them.

## Getting Started

*to be copied from http://www.orocos.org/stable/documentation/rtt/v2.x/doc-xml/orocos-installation.html*

## Cross Compiling Orocos

*to be copied from http://www.orocos.org/stable/documentation/rtt/v2.x/doc-xml/orocos-installation.html*
