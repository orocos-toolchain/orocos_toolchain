#!/bin/bash

set -e            # abort on error
#cd $(dirname $0)

# ##############################################################################
# Default options
# ##############################################################################
DEFAULT_PREFIX=/usr/local
: ${PREFIX:=$DEFAULT_PREFIX}
if [ -e .git ]; then
  # build in-source
  DEFAULT_SOURCES=`readlink -fm . 2>/dev/null || readlink . || echo $PWD`
else
  # build out of source
  DEFAULT_SOURCES=`readlink -fm src/orocos-toolchain 2>/dev/null || readlink src/orocos-toolchain || echo src/orocos-toolchain`
fi
: ${SOURCES:=$DEFAULT_SOURCES}
DEFAULT_GIT_BASE_URL=https://github.com/orocos-toolchain/
: ${GIT_BASE_URL:=$DEFAULT_GIT_BASE_URL}
DEFAULT_GIT_BRANCH=
: ${GIT_BRANCH:=$DEFAULT_GIT_BRANCH}
DEFAULT_CMAKE_BUILD_TYPE=Release
: ${CMAKE_BUILD_TYPE:=$DEFAULT_CMAKE_BUILD_TYPE}
CMAKE_ARGS=( )
MAKE_ARGS=( )

VERBOSE=
YES=
CLEAN=

# assumption: Git remote URL = ${GIT_BASE_URL}${PACKAGES[i]}.git
PACKAGES=(
  log4cpp
  rtt
  ocl
  #utilrb
  #typelib
  #rtt_typelib
  #orogen
  orocos_toolchain
)


FEATURES=( corba mqueue tests )
FEATURES_ENABLED=( )
FEATURES_DISABLED=( )
: ${CORBA_IMPLEMENTATION:=OMNIORB}
: ${OROCOS_TARGET:=}

# ##############################################################################
# Functions
# ##############################################################################
function help()
{
  cat << EOF >&2
Usage: ${0##*/} [options]

This installation script will assist you with the process of

 * cloning the Orocos toolchain source repositories using git
 * configuring Orocos and
 * building and installing Orocos.

    -h,--help               Show this help
    -v,--verbose            Be more verbose

  Git options:

    --branch, -b <branch>   Clone/checkout branch of all source repositories
                            (default: upstream HEAD)
    --url, -u <url>         Git base url (default: ${DEFAULT_GIT_BASE_URL})

  Build and configuration options:

    --prefix <prefix>       The installation prefix (default: ${DEFAULT_PREFIX})
    --source, -s <dir>      The source directory (default: ${DEFAULT_SOURCES})
    --clean, -c             Clean build folder before rebuilding
    -d, --debug[=CMAKE_BUILD_TYPE]
                            Build in Debug mode. The argument is optional and
                            overwrites the default CMAKE_BUILD_TYPE Debug.
                            The default build type without the --debug option
                            is ${DEFAULT_CMAKE_BUILD_TYPE}.
    --target, -t            The OROCOS target platform, one of [gnulinux, lxrt,
                            xenomai, ecos, macosx, win32]. If not specified,
                            Orocos will figure this out itself.

    --enable-<feature>      Enable feature or plugin <feature> (see below)
    --disable-<feature>     Disable feature or plugin <feature> (see below)

    -D<var>=<value>         Set cmake variable
    --cmake-args            Arbitrary arguments which are passes to cmake.
                            Collects all of following arguments until a "--" is
                            read.
    --make-args             Arbitrary arguments which are passes to make.
                            Collects all of following arguments until a "--" is
                            read.
    -j [N], --jobs[=N]      Allow N jobs at once; infinite jobs with no arg.

  Known features (for --(enable|disable)-<feature> options):
    * corba:   The CORBA transport plugin
    * mqueue:  The POSIX message queue transport plugin
    * tests:   Enable tests

EOF
}

# missing_dependencies=( )
# function do_check_dependencies()
# {
#   # cmake
#   cmake=`which cmake >/dev/null 2>/dev/null`
#   if [ -z "$cmake" ]; then
#     do_install_system_package cmake
#   else
#     cmake_version=`${cmake} --version`
#     cmake_version=${cmake_version#cmake version }
#     echo "[${SCRIPT_NAME}]  Found cmake version ${cmake_version} in ${cmake}." >&2
#   fi
#
#   # boost
#   if ! ${cmake} --find-package -DNAME=Boost -DCOMPILER=GNU -DLANGUAGE=CXX -DMODE=EXIST >/dev/null 2>&1; then
#     do_install_system_package boost
#   else
#     echo "[${SCRIPT_NAME}]  Found Boost." >&2
#   fi
#
#   # warn about missing dependencies
#   if [ -n "${missing_dependencies}" ]; then
#     echo "The following system dependencies could not be found:" >&2
#     for dep in "${missing_dependencies[@]}"; do
#       echo " - ${dep}" >&2
#     done
#     echo >&2
#     echo -n "Continue anyway [Y/n]? " >&2
#     read -n1 response
#     echo >&2
#     if [[ "$response" = "n" || "$response" = "N" ]]; then exit 1; fi
#   fi
# }
#
# function do_install_system_package()
# {
#   # skip installation if --no-deps was given in the command line
#   if [ "$NO_DEPS" = true ]; then
#     missing_dependencies+=( $1 )
#     return
#   fi
#
#   # forward to the correct system tool depending on the OS
#   if [[ "$LINUX_DISTRO" == "Ubuntu" ||
#         "$LINUX_DISTRO" == "Debian" ]]; then
#     do_install_system_package_debian "$@"
#     return
#   fi
#
#   missing_dependencies+=( $1 )
# }
#
# function do_install_system_package_debian()
# {
#   debian_packages=
#   case "$1" in
#     boost)
#       debian_packages=libboost-all-dev ;;
#     cmake)
#       debian_packages=cmake ;;
#   esac
#
#   for pkg in ${debian_packages}; do
#     # check if the package is already installed
#     if [ `/usr/bin/dpkg-query -W -f='${Status}' $pkg` = "install ok installed" ]; then
#       continue
#     fi
#     # check if the package is already installed
#     do_run apt-get install $YES $pkg
#   done
# }

function do_clone_sources()
{
  # create source directory
  do_run mkdir -p ${SOURCES}

  # clone orocos_toolchain repository to ${SOURCES}
  do_clone_package_source_or_check_branch orocos_toolchain "${SOURCES}" ${GIT_BRANCH}

  # clone all other package repositories to ${SOURCES}/package
  for pkg in "${PACKAGES[@]}"; do
    if [ "$pkg" = "orocos_toolchain" ]; then continue; fi
    do_clone_package_source_or_check_branch $pkg "${SOURCES}/$pkg" ${GIT_BRANCH}
  done
}

function do_clone_package_source_or_check_branch()
{
  pkg="$1"
  dir="$2"
  git_branch="$3"

  # compose branch option
  git_branch_option=
  if [ -n "${git_branch}" ]; then
    git_branch_option="-b ${git_branch}"
  fi

  if [[ ! -f "${dir}/CMakeLists.txt" && ! -f "${dir}/.gitmodules" ]]; then
    [ -n "$VERBOSE" ] && echo "[$SCRIPT_NAME] Cloning $pkg to ${dir}." >&2
    do_run git clone --recursive ${git_branch_option} "${GIT_BASE_URL}${pkg}.git" "${dir}"
  else
    [ -n "$VERBOSE" ] && echo "[$SCRIPT_NAME] Found ${pkg} in ${dir}." >&2

    if [ -e "${dir}/.git" ]; then
      current_git_branch=`cd "${dir}" && git rev-parse --abbrev-ref HEAD`
      if [[ -n "$current_git_branch" && -n "$git_branch"
            && "$current_git_branch" != "$git_branch" ]]; then
        [ -n "$VERBOSE" ] && echo "[$SCRIPT_NAME] Checking out branch '${git_branch}' of the source repository for package $pkg..." >&2
        (
          do_run cd "${dir}" && do_run git checkout ${git_branch}
        )
      fi
    fi
  fi
}

function do_build_and_install()
{
  # clean build folder
  if [ "$CLEAN" = true ]; then
    do_run rm -rf build/
  fi

  # set CMAKE_BUILD_TYPE
  if [ -n "$CMAKE_BUILD_TYPE" ]; then
    CMAKE_ARGS=( -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} "${CMAKE_ARGS[@]}" )
  fi

  # set OROCOS_TARGET
  if [ -n "$OROCOS_TARGET" ]; then
    CMAKE_ARGS+=( -DOROCOS_TARGET="${OROCOS_TARGET}" )
  fi

  # add additional cmake options for enabled features
  FEATURE_CMAKE_ARGS=( )
  for feature in "${FEATURES[@]}"; do
    case "$feature" in
      corba)
        if is_feature_enabled $feature; then
          FEATURE_CMAKE_ARGS+=( -DENABLE_CORBA=ON )
          if [ "${CMAKE_ARGS[$@]}" != "*-DCORBA_IMPLEMENTATION=*" ]; then
            FEATURE_CMAKE_ARGS+=( -DCORBA_IMPLEMENTATION=${CORBA_IMPLEMENTATION} )
          fi
        elif is_feature_disabled $feature; then
          FEATURE_CMAKE_ARGS+=( -DENABLE_CORBA=OFF )
        fi ;;
      mqueue)
        if is_feature_enabled $feature; then
          FEATURE_CMAKE_ARGS+=( -DENABLE_MQ=ON )
        elif is_feature_disabled $feature; then
          FEATURE_CMAKE_ARGS+=( -DENABLE_MQ=OFF )
        fi ;;
      tests)
        if is_feature_enabled $feature; then
          FEATURE_CMAKE_ARGS+=( -DENABLE_TESTS=ON )
        elif is_feature_disabled $feature; then
          FEATURE_CMAKE_ARGS+=( -DENABLE_TESTS=OFF )
        fi ;;
    esac
  done

  # enable verbosity in make
  if [ -n "$VERBOSE" ]; then
    MAKE_ARGS+=( VERBOSE=1 )
  fi

  # build and install packages
  for pkg in "${PACKAGES[@]}"; do
    if [ ! -d "${SOURCES}/$pkg" ]; then continue; fi

    echo "*******************************************************************************" >&2
    echo "** Building package $pkg" >&2
    echo "*******************************************************************************" >&2
    do_run mkdir -p build/$pkg && do_run pushd build/$pkg >/dev/null
    do_run cmake "${SOURCES}/$pkg" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      "${FEATURE_CMAKE_ARGS[@]}" "${CMAKE_ARGS[@]}"
    do_run make ${JOBS} "${MAKE_ARGS[@]}"
    do_run make install
    do_run popd
    echo >&2
  done
}

function do_run()
{
  if [ -n "${VERBOSE}" ]; then
    echo "[${SCRIPT_NAME}] Executing \`$@\`" >&2
  fi
  "$@"
  return $?
}

function is_feature_enabled()
{
  for x in "${FEATURES_ENABLED[@]}"; do
    if [ "$x" = "$1" ]; then return 0; fi
  done
  return 1
}

function is_feature_disabled()
{
  for x in "${FEATURES_DISABLED[@]}"; do
    if [ "$x" = "$1" ]; then return 0; fi
  done
  return 1
}

# ##############################################################################
# Detect platform settings
# ##############################################################################
PLATFORM=`uname -s || true`
if [ "$PLATFORM" = "Linux" ]; then
  LINUX_DISTRO=`lsb_release -si || true`
  LINUX_CODENAME=`lsb_release -sc || true`
fi

# ##############################################################################
# Parse command line options
# ##############################################################################
SCRIPT_NAME="${0##*/}"

# copy command line options to OPTIONS array and parse --make-args, --cmake-args,
# -D... and --enable-* and --disable-* options because getopt cannot handle them
declare -a OPTIONS
while [ $# -gt 0 ]; do
  case "$1" in
    -D*)
      CMAKE_ARGS+=( "$1" )
      shift ;;
    --make-args)
      shift
      while [ $# -gt 0 ]; do
        if [ "$1" == "--" ]; then
          shift
          break
        fi
        MAKE_ARGS+=( "$1" )
        shift
      done ;;
    --cmake-args)
      shift
      while [ $# -gt 0 ]; do
        if [ "$1" == "--" ]; then
          shift
          break
        fi
        CMAKE_ARGS+=( "$1" )
        shift
      done ;;
    --enable-*)
      FEATURES_ENABLED+=( "${1#--enable-}" )
      shift ;;
    --disable-*)
      FEATURES_DISABLED+=( "${1#--disable-}" )
      shift ;;
    *)
      OPTIONS+=( "$1" )
      shift ;;
  esac
done

# parse remaining command line options
TEMP=`getopt \
  --options -hvyb:u:s:cd::t:j:: \
  --long help,verbose,branch:,url:,no-deps,yes,prefix:,source:,clean,debug::,target:,jobs:: \
  -n "${SCRIPT_NAME}" -- "${OPTIONS[@]}"`
if [ $? -ne 0 ]; then exit $?; fi
eval set -- "$TEMP"

while true; do
  case "$1" in
    -h|--help)
      help
      exit 0 ;;
    -v|--verbose)
      VERBOSE=-v
      shift ;;
    -y|--yes)
      YES=-y
      shift ;;
    -b|--branch)
      GIT_BRANCH="$2"
      shift 2 ;;
    -u|--url)
      GIT_BASE_URL="$2"
      if [ "${GIT_URL}" = "${GIT_BASE_URL%/}" ]; then
        GIT_BASE_URL="${GIT_BASE_URL}/"
      fi
      shift 2 ;;
    --no-deps)
      NO_DEPS=true
      shift ;;
    --prefix)
      PREFIX=`readlink -fm "$2" 2>/dev/null || readlink "$2" || echo "$2"`
      shift 2 ;;
    -s|--source)
      SOURCES=`readlink -fm "$2" 2>/dev/null || readlink "$2" || echo "$2"`
      shift 2 ;;
    -c|--clean)
      CLEAN=true
      shift ;;
    -d|--debug)
      CMAKE_BUILD_TYPE="$2"
      : ${CMAKE_BUILD_TYPE:=Debug}
      shift 2 ;;
    -t|--target)
      OROCOS_TARGET="$2"
      shift 2 ;;
    -j|--jobs)
      JOBS="-j$2"
      shift 2 ;;
    --)
      shift; break ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1 ;;
  esac
done

if [ -n "$VERBOSE" ]; then
  [ -n "${PLATFORM}" ]                      && echo "[$SCRIPT_NAME] Detected platform: ${PLATFORM}" >&2
  [ -n "${LINUX_DISTRO}${LINUX_CODENAME}" ] && echo "[$SCRIPT_NAME] Detected distribution: ${LINUX_DISTRO} ${LINUX_CODENAME}" >&2
  [ -n "${SOURCES}" ]                       && echo "[$SCRIPT_NAME] Building from sources in ${SOURCES}" >&2
  [ -n "${OROCOS_TARGET}" ]                 && echo "[$SCRIPT_NAME] Building for OROCOS target \"${OROCOS_TARGET}\"" >&2
  [ -n "${CMAKE_BUILD_TYPE}" ]              && echo "[$SCRIPT_NAME] Building with CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE}" >&2
  [ -n "${PREFIX}" ]                        && echo "[$SCRIPT_NAME] Installing to ${PREFIX}" >&2
  [ -n "${FEATURES_ENABLED}" ]              && echo "[$SCRIPT_NAME] Enabled OROOCS features: ${FEATURES_ENABLED}" >&2
  [ -n "${FEATURES_DISABLED}" ]             && echo "[$SCRIPT_NAME] Disabled OROCOS features: ${FEATURES_DISABLED}" >&2
  [ -n "${JOBS}" ]                          && echo "[$SCRIPT_NAME] Make job options: ${JOBS}" >&2
  echo >&2
fi

# ##############################################################################
#  Main
# ##############################################################################
#do_check_dependencies
do_clone_sources
do_build_and_install

# ##############################################################################
#  Success message
# ##############################################################################
echo "*******************************************************************************" >&2
echo "** DONE!" >&2
echo "*******************************************************************************" >&2
echo "Successfully built and installed the following packages:" >&2
for pkg in "${PACKAGES[@]}"; do
  echo " - ${pkg}" >&2
done
echo >&2

if [ -f "${PREFIX}/setup.sh" ]; then
  cat <<END >&2
You should source the setup.sh script in the installation folder to setup your environment
before you continue:

  . ${PREFIX}/setup.sh

END
elif [ -f "${PREFIX}/etc/orocos/setup.sh" ]; then
  cat <<END >&2
You should source the setup.sh script in etc/orocos/setup.sh to setup your environment
before you continue:

  . ${PREFIX}/etc/orocos/setup.sh

END
fi
