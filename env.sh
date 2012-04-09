
RUBY_VERSION=`ruby --version | awk '{ print $2; }' | sed -e "s/\(.*\..*\)\..*/\1/"`
RUBY_ARCH=`ruby --version | sed -e 's/.*\[\(.*\)\]/\1/'`
export RUBYOPT=-rubygems
export TYPELIB_USE_GCCXML=1


if [ x$ROS_ROOT != x ]; then
### ROS
export RUBYLIB=`rospack find utilrb`/lib:`rospack find orogen`/lib:`rosstack find orocos_toolchain`/install/lib/ruby/${RUBY_VERSION}/${RUBY_ARCH}:`rosstack find orocos_toolchain`/install/lib/ruby/${RUBY_VERSION}
export GEM_HOME=`rosstack find orocos_toolchain`/.gems
export PATH=`rosstack find orocos_toolchain`/install/bin:`rospack find orogen`/bin:`rosstack find orocos_toolchain`/.gems/bin:$PATH
export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:`rosstack find orocos_toolchain`/install/lib/pkgconfig

elif [ x${BASH} != x ]; then
### Bash non-ROS
cd `dirname ${BASH_SOURCE[0]}`
envpath=$PWD
cd - > /dev/null
export RUBYLIB=$envpath/utilrb/lib:$envpath/orogen/lib:$envpath/install/lib/ruby/${RUBY_VERSION}/${RUBY_ARCH}:$envpath/install/lib/ruby/${RUBY_VERSION}
export GEM_HOME=$envpath/.gems
export PATH=$envpath/install/bin:$envpath/orogen/bin:$envpath/.gems/bin:$PATH
export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:$envpath/install/lib/pkgconfig

elif [ `basename $PWD` = orocos_toolchain ]; then
### non-Bash, non-ROS
export RUBYLIB=$PWD/utilrb/lib:$PWD/orogen/lib:$PWD/install/lib/ruby/${RUBY_VERSION}/${RUBY_ARCH}:$PWD/install/lib/ruby/${RUBY_VERSION}
export GEM_HOME=$PWD/.gems
export PATH=$PWD/install/bin:$PWD/orogen/bin:$PWD/.gems/bin:$PATH
export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:$PWD/install/lib/pkgconfig
else
  echo "Error: This script must be sourced from the 'orocos_toolchain' directory when not running in a ROS_ROOT nor bash environment."
  echo  
fi
