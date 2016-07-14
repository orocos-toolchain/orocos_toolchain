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

  set(OROCOS_SETUP_DESTINATION "etc/orocos")
  configure_file(../setup.sh ${CMAKE_CURRENT_BINARY_DIR}/setup.sh @ONLY)
  configure_file(../env.sh ${CMAKE_CURRENT_BINARY_DIR}/env.sh @ONLY)
  if(NOT OROCOS_SETUP_DESTINATION)
    # Install setup files directly to CMAKE_INSTALL_PREFIX, but
    # we do not want to override setup files installed by catkin.
    install(CODE "
      if(NOT EXISTS \"\${CMAKE_INSTALL_PREFIX}/setup.sh\")
        file(INSTALL
          \"${CMAKE_CURRENT_BINARY_DIR}/setup.sh\"
          DESTINATION \"\${CMAKE_INSTALL_PREFIX}\"
        )
      else()
        message(STATUS \"Keep original: \${CMAKE_INSTALL_PREFIX}/setup.sh\")
      endif()
      if(NOT EXISTS \"\${CMAKE_INSTALL_PREFIX}/env.sh\")
        file(INSTALL
          \"${CMAKE_CURRENT_BINARY_DIR}/env.sh\"
          DESTINATION \"\${CMAKE_INSTALL_PREFIX}\"
          FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
        )
      else()
        message(STATUS \"Keep original: \${CMAKE_INSTALL_PREFIX}/env.sh\")
      endif()
    ")
  else()
    install(FILES
      "${CMAKE_CURRENT_BINARY_DIR}/setup.sh"
      DESTINATION "${CMAKE_INSTALL_PREFIX}/${OROCOS_SETUP_DESTINATION}"
    )
    install(PROGRAMS
      "${CMAKE_CURRENT_BINARY_DIR}/env.sh"
      DESTINATION "${CMAKE_INSTALL_PREFIX}/${OROCOS_SETUP_DESTINATION}"
    )
  endif()
endif()
