cmake_minimum_required(VERSION 2.8.3)
project(orocos_toolchain)
find_package(catkin REQUIRED)
catkin_metapackage()

catkin_add_env_hooks(orocos SHELLS bash DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/env-hooks)
