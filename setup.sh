#!/bin/sh
#
# The purpose of this script is to setup the environment for the Orocos Toolchain.
#
# Usage: . @CMAKE_INSTALL_PREFIX@/@OROCOS_SETUP_DESTINATION@/setup.sh
#
# This file will be installed to CMAKE_INSTALL_PREFIX by cmake with the
# @-references replaced by the value of the respective cmake variable.
#

# find OROCOS installation folder from CMAKE_INSTALL_PREFIX, BASH_SOURCE or $_
case "@CMAKE_INSTALL_PREFIX@" in
  @*) ;;
  *)  OROCOS_INSTALL_PREFIX="@CMAKE_INSTALL_PREFIX@" ;;
esac
if [ -z "$OROCOS_INSTALL_PREFIX" ]; then
  if [ -n "$BASH_SOURCE" ]; then
    OROCOS_INSTALL_PREFIX=`dirname ${BASH_SOURCE[0]}`
    OROCOS_INSTALL_PREFIX=`cd ${OROCOS_INSTALL_PREFIX}; pwd`
  elif [ -n "$_" ]; then
    OROCOS_INSTALL_PREFIX=`dirname $_`
    OROCOS_INSTALL_PREFIX=`cd ${OROCOS_INSTALL_PREFIX}; pwd`
  else
    echo "Could not determine the OROCOS installation prefix for your shell." >&2
    exit 1
  fi
fi

# initialize OROCOS_TARGET if unset
if [ -z "${OROCOS_TARGET}" ]; then
  case "@OROCOS_TARGET@" in
    @*) ;;
    *)  OROCOS_TARGET="@OROCOS_TARGET@" ;;
  esac
fi

# add bin/ to PATH
if [ -d ${OROCOS_INSTALL_PREFIX}/bin ]; then
  if ! echo $PATH | grep -q "${OROCOS_INSTALL_PREFIX}/bin"; then
    PATH="${PATH}:${OROCOS_INSTALL_PREFIX}/bin"
  fi
fi

# add OROCOS_INSTALL_PREFIX to CMAKE_PREFIX_PATH
if [ -d ${OROCOS_INSTALL_PREFIX} ]; then
  if ! echo $CMAKE_PREFIX_PATH | grep -q "${OROCOS_INSTALL_PREFIX}"; then
    if [ -z "$CMAKE_PREFIX_PATH" ]; then
      CMAKE_PREFIX_PATH="${OROCOS_INSTALL_PREFIX}"
    else
      CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}:${OROCOS_INSTALL_PREFIX}"
    fi
  fi
fi

# add lib/orocos to RTT_COMPONENT_PATH
# Note: The rtt env-hook also sets the RTT_COMPONENT_PATH variable. We could
# remove this redundant section.
if [ -d ${OROCOS_INSTALL_PREFIX}/lib/orocos ]; then
  if ! echo $RTT_COMPONENT_PATH | grep -q "${OROCOS_INSTALL_PREFIX}/lib/orocos"; then
    if [ -z "$RTT_COMPONENT_PATH" ]; then
      RTT_COMPONENT_PATH="${OROCOS_INSTALL_PREFIX}/lib/orocos"
    else
      RTT_COMPONENT_PATH="${RTT_COMPONENT_PATH}:${OROCOS_INSTALL_PREFIX}/lib/orocos"
    fi
  fi
fi

# add lib/pkgconfig to PKG_CONFIG_PATH
if [ -d ${OROCOS_INSTALL_PREFIX}/lib/pkgconfig ]; then
  if ! echo $PKG_CONFIG_PATH | grep -q "${OROCOS_INSTALL_PREFIX}/lib/pkgconfig"; then
    if [ -z "$PKG_CONFIG_PATH" ]; then
      PKG_CONFIG_PATH="${OROCOS_INSTALL_PREFIX}/lib/pkgconfig"
    else
      PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${OROCOS_INSTALL_PREFIX}/lib/pkgconfig"
    fi
  fi
fi

# find and source target-specific env-hooks in etc/orocos/profile.d
for hook in ${OROCOS_INSTALL_PREFIX}/etc/orocos/profile.d/*.sh; do
  [ -f $hook ] && . ${hook}
done

# export environment variables
export OROCOS_INSTALL_PREFIX
export OROCOS_TARGET
export PATH
export CMAKE_PREFIX_PATH
export RTT_COMPONENT_PATH
export PKG_CONFIG_PATH
