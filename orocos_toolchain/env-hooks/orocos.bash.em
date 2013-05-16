RUBY_VERSION=`ruby --version | awk '{ print $2; }' | sed -e "s/\(.*\..*\)\..*/\1/"`
RUBY_ARCH=`ruby --version | sed -e 's/.*\[\(.*\)\]/\1/'`
export RUBYOPT=-rubygems
export TYPELIB_USE_GCCXML=1


envpath=@CMAKE_INSTALL_PREFIX@

if [ `uname -s` = Darwin ]; then
export RUBYLIB=$envpath/lib:$envpath/lib/typelib:$envpath/lib/ruby/${RUBY_VERSION}/${RUBY_ARCH}:$envpath/lib/ruby/${RUBY_VERSION}:/Library/Ruby/Gems/${RUBY_VERSION}:\
/Library/Ruby/Gems/${RUBY_VERSION}/${RUBY_ARCH}:/Library/Ruby/Gems
export DYLD_LIBRARY_PATH=$envpath/lib/typelib:$envpath/lib/orocos:$DYLD_LIBRARY_PATH
else
export RUBYLIB=$envpath/lib:$envpath/lib/typelib:$envpath/lib/ruby/${RUBY_VERSION}/${RUBY_ARCH}:$envpath/lib/ruby/${RUBY_VERSION}:
export LD_LIBRARY_PATH=$envpath/lib/typelib:$envpath/lib/orocos:$LD_LIBRARY_PATH
fi
if [ "x$LUA_PATH" == "x" ];then
    LUA_PATH=";;;"
fi
export LUA_PATH="$LUA_PATH;$envpath/share/lua/5.1/?.lua"
