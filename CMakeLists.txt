##
## Top-level CMakeLists.txt to build and install the whole Orocos Toolchain
##

cmake_minimum_required(VERSION 2.8)

# capture CMake arguments specified at the command-line
# (taken from https://stackoverflow.com/a/48555098)

# MUST be done before call to 'project'
get_cmake_property(vars CACHE_VARIABLES)
foreach(var ${vars})
  if(NOT var MATCHES "^(CMAKE_INSTALL_PREFIX|CMAKE_BUILD_TYPE|GIT_BASE_URL|GIT_TAG|OROCOS_TARGET|BUILD_STATIC|ENABLE_CORBA|CORBA_IMPLEMENTATION)$")
    get_property(currentHelpString CACHE "${var}" PROPERTY HELPSTRING)
    if("${currentHelpString}" MATCHES "No help, variable specified on the command line." OR "${currentHelpString}" STREQUAL "")
      #message("${var} = [${${var}}]  --  ${currentHelpString}") # uncomment to see the variables being processed
      list(APPEND CL_ARGS "-D${var}=${${var}}")
    endif()
  endif()
endforeach()

project(orocos_toolchain)

######################
# Build-time options #
######################

# get absolute CMAKE_INSTALL_PREFIX
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/install")
endif()
set(CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH "Install path prefix, prepended onto install directories" FORCE)
message(STATUS "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}")

# (copied from rtt/orocos-rtt.default.cmake)

#
# Sets the CMAKE_BUILD_TYPE to Release by default. This is not a normal
# CMake flag which is not readable during configuration time.
if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Choose the type of build, options are: None(CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()

#
# Set the target operating system. One of [lxrt gnulinux xenomai macosx win32]
# You may leave this as-is or force a certain target by removing the if... logic.
#
set(DOC_STRING "The Operating System target. One of [gnulinux lxrt macosx win32 xenomai]")
set(OROCOS_TARGET_ENV $ENV{OROCOS_TARGET}) # MUST use helper variable, otherwise not picked up !!!
if( OROCOS_TARGET_ENV )
  set(OROCOS_TARGET ${OROCOS_TARGET_ENV} CACHE STRING "${DOC_STRING}" FORCE)
  message(STATUS "Detected OROCOS_TARGET environment variable. Using: ${OROCOS_TARGET}")
else()
  if(NOT DEFINED OROCOS_TARGET )
    if(MSVC)
      set(OROCOS_TARGET win32    CACHE STRING "${DOC_STRING}")
    elseif(APPLE AND ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
      set(OROCOS_TARGET macosx   CACHE STRING "${DOC_STRING}")
    else()
      set(OROCOS_TARGET gnulinux CACHE STRING "${DOC_STRING}")
    endif()
  endif()
  message(STATUS "No OROCOS_TARGET environment variable set. Using: ${OROCOS_TARGET}")
endif()

# (copied from rtt/config/check_depend.cmake)

#
# Build static libraries?
#
option(BUILD_STATIC "Build Orocos RTT as a static library." OFF)

#
# CORBA
#
option(ENABLE_CORBA "Enable CORBA" OFF)
if(NOT CORBA_IMPLEMENTATION)
  set(CORBA_IMPLEMENTATION "TAO" CACHE STRING "The implementation of CORBA to use (allowed values: TAO or OMNIORB )" )
else()
  set(CORBA_IMPLEMENTATION ${CORBA_IMPLEMENTATION} CACHE STRING "The implementation of CORBA to use (allowed values: TAO or OMNIORB )" )
endif()

#############
# Git magic #
#############

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/.git")
  set(IS_GIT TRUE)
else()
  set(IS_GIT FALSE)
endif()

set(GIT_BASE_URL "https://github.com/orocos-toolchain/")
set(GIT_TAG "" CACHE STRING "Git branch or tag to checkout in submodules. If empty, use the commits tracked by submodules or the default branches.")

if(GIT_TAG)
  message(STATUS "Building branch or tag ${GIT_TAG} for all submodules.")
endif()

#################################
# Build and install subprojects #
#################################

include(ExternalProject)
function(build_external_project project)
  cmake_parse_arguments(ARG "" "" "CMAKE_ARGS" ${ARGN})

  set(${project}_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${project})
  set(${project}_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${project})

  if(IS_GIT)
    # Use the submodules...
    set(DOWNLOAD_AND_UPDATE_OPTIONS
      DOWNLOAD_COMMAND
        cd "${CMAKE_CURRENT_SOURCE_DIR}" && test -e ${project}/.git || git submodule update --init ${project}
    )

    # Specific branch/tag?
    if(GIT_TAG)
      list(APPEND DOWNLOAD_AND_UPDATE_OPTIONS
        UPDATE_COMMAND
          cd "${CMAKE_CURRENT_SOURCE_DIR}/${project}" && git checkout "${GIT_TAG}"
      )
    endif()

  else()
    # Clone from remote repository...
    set(DOWNLOAD_AND_UPDATE_OPTIONS
      GIT_REPOSITORY "${GIT_BASE_URL}${project}.git"
      GIT_TAG "${GIT_TAG}"
    )
  endif()

  # Set PKG_CONFIG_PATH to be used by subprojects
  set(PKG_CONFIG_PATH "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")

  ExternalProject_Add(${project}
    PREFIX ${project}
    TMP_DIR "${CMAKE_CURRENT_BINARY_DIR}/tmp"
    STAMP_DIR "${CMAKE_CURRENT_BINARY_DIR}/stamp"
    DOWNLOAD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${project}"
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${project}"
    BINARY_DIR "${${project}_BINARY_DIR}"
    INSTALL_DIR "${CMAKE_INSTALL_PREFIX}"

    ${DOWNLOAD_AND_UPDATE_OPTIONS}
    PATCH_COMMAND #nothing
    BUILD_ALWAYS ON

    CMAKE_COMMAND
      ${CMAKE_COMMAND} -E env "PKG_CONFIG_PATH=${PKG_CONFIG_PATH}" ${CMAKE_COMMAND}

    CMAKE_ARGS
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
      -DOROCOS_TARGET=${OROCOS_TARGET}
      ${ARG_CMAKE_ARGS}

    ${ARG_UNPARSED_ARGUMENTS}
  )
endfunction()

build_external_project(log4cpp)
build_external_project(rtt
  CMAKE_ARGS
    -DENABLE_CORBA=${ENABLE_CORBA}
    -DCORBA_IMPLEMENTATION=${CORBA_IMPLEMENTATION}
    -DBUILD_STATIC=${BUILD_STATIC}
)
build_external_project(ocl
  DEPENDS log4cpp rtt
)

build_external_project(utilrb)
build_external_project(typelib
  DEPENDS utilrb
)
build_external_project(rtt_typelib
  DEPENDS typelib
)
build_external_project(orogen
  DEPENDS rtt rtt_typelib utilrb
)

#######################################
# Build orocos_toolchain meta package #
#######################################

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/orocos_toolchain)
  add_subdirectory(orocos_toolchain)
endif()

