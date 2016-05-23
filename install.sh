#!/bin/bash

function help()
{

}

function do_check_dependencies()
{

}

function do_download_sources()
{

}

function do_build()
{

}

# ##############################################################################
# Detect platform settings
# ##############################################################################
PLATFORM=`uname -s || true`
LINUX_DISTRO=`lsb_release -si`
LINUX_CODENAME=`lsb_release -sc`

# ##############################################################################
# Parse command line options
# ##############################################################################


# ##############################################################################
# Execution
# ##############################################################################
set -e
do_check_dependencies
do_download_sources
do_build
