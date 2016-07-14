#!/bin/sh
#
# The purpose of this script is to setup the environment for the Orocos Toolchain
# (like setup.sh) and execute a command.
#
# Usage: env.sh COMMANDS
#
# This file will be installed to CMAKE_INSTALL_PREFIX by cmake with the
# @-references replaced by the value of the respective cmake variable.
#

if [ $# -eq 0 ] ; then
  /bin/echo "Usage: env.sh COMMANDS" >&2
  if [ -z "$BASH_SOURCE" -a -z "$_" ]; then
    exit 1
  else
    return
  fi
fi

# find OROCOS installation folder from CMAKE_INSTALL_PREFIX or $0
case "@CMAKE_INSTALL_PREFIX@" in
  @*) ;;
  *)  OROCOS_INSTALL_PREFIX="@CMAKE_INSTALL_PREFIX@" ;;
esac
if [ -z "$OROCOS_INSTALL_PREFIX" ]; then
  OROCOS_INSTALL_PREFIX=`dirname $0`
  OROCOS_INSTALL_PREFIX=`cd ${OROCOS_INSTALL_PREFIX}; pwd`
fi

# source setup.sh
if [ -f ${OROCOS_INSTALL_PREFIX}/setup.sh ]; then
  . ${OROCOS_INSTALL_PREFIX}/setup.sh
elif [ -f ${OROCOS_INSTALL_PREFIX}/etc/orocos/setup.sh ]; then
  . ${OROCOS_INSTALL_PREFIX}/etc/orocos/setup.sh
elif [ -f /etc/orocos/setup.sh ]; then
  . /etc/orocos/setup.sh
else
  echo "env.sh: could not find Orocos setup.sh script" >&2
  exit 1
fi

# execute command
exec "$@"
