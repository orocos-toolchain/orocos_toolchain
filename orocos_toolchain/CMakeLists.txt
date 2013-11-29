cmake_minimum_required(VERSION 2.8.3)
project(orocos_toolchain)
find_package(catkin REQUIRED)
catkin_metapackage()

# SHELLS sh works for all shells
catkin_add_env_hooks(orocos_toolchain SHELLS sh DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/env-hooks)
