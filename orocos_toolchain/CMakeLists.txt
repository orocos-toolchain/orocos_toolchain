cmake_minimum_required(VERSION 2.8.3)
project(orocos_toolchain)

find_package(catkin QUIET)
if(catkin_FOUND)
  catkin_metapackage()

else()
  install(FILES
    package.xml
    DESTINATION share/${PROJECT_NAME}/
  )
endif()
