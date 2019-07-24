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

# need to find Orocos RTT to set OROCOS_TARGET and other cmake variables
find_package(OROCOS-RTT REQUIRED)

set(OROCOS_SETUP_DESTINATION "etc/orocos" CACHE STRING "Destination folder for Orocos setup files (setup.sh, env.sh), relative to CMAKE_INSTALL_PREFIX")
configure_file(../setup.sh ${CMAKE_CURRENT_BINARY_DIR}/setup.sh @ONLY)
configure_file(../env.sh ${CMAKE_CURRENT_BINARY_DIR}/env.sh @ONLY)

if(OROCOS_SETUP_DESTINATION)
  install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/setup.sh"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/${OROCOS_SETUP_DESTINATION}"
  )
  install(PROGRAMS
    "${CMAKE_CURRENT_BINARY_DIR}/env.sh"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/${OROCOS_SETUP_DESTINATION}"
  )
endif()

# Install setup files directly to CMAKE_INSTALL_PREFIX if we are not
# installing to a default location, but do not override setup files
# installed by catkin or when building a binary package using bloom.
if(NOT CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT
   AND NOT CMAKE_INSTALL_PREFIX STREQUAL "/usr"
   AND NOT CMAKE_INSTALL_PREFIX STREQUAL "/usr/local"
   AND NOT CATKIN_BUILD_BINARY_PACKAGE)
  install(CODE "
    if(NOT EXISTS \"\${CMAKE_INSTALL_PREFIX}/setup.sh\")
      file(INSTALL
        \"${CMAKE_CURRENT_BINARY_DIR}/setup.sh\"
        DESTINATION \"\${CMAKE_INSTALL_PREFIX}\"
      )
    else()
      message(STATUS \"Keeping original: \${CMAKE_INSTALL_PREFIX}/setup.sh\")
    endif()
    if(NOT EXISTS \"\${CMAKE_INSTALL_PREFIX}/env.sh\")
      file(INSTALL
        \"${CMAKE_CURRENT_BINARY_DIR}/env.sh\"
        DESTINATION \"\${CMAKE_INSTALL_PREFIX}\"
        FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
      )
    else()
      message(STATUS \"Keeping original: \${CMAKE_INSTALL_PREFIX}/env.sh\")
    endif()
  ")
endif()
