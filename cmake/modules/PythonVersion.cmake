# This module provides macros related to different versions of the python interpreter.
#
# .. cmake_function:: dune_require_python_version
#
#    .. cmake_param:: version
#       :positional:
#       :single:
#       :required:
#
#       The minimum required version.
# 
#    Error out, if the python interpreter found by cmake is older than the given version.
#    Python2 and Pyhton3 versions are not compared to each other, so you can call this
#    macro multiple times to enforce minimal versions on a python2 and python3 interpreter
#    independently.
#
# .. cmake_function:: dune_force_python_version
#
#    .. cmake_param:: version
#       :positional:
#       :single:
#       :required:
#
#       The major python version: 2 or 3
#
#    Enforce the major version of the python interpreter to be either 2 or 3.
#


macro(dune_require_python_version version)
  string(REPLACE "." ";" versionlist ${version})
  list(GET versionlist 0 major)
  if("${major}" STREQUAL "2")
    # This is a python2 requirement.
    if("${PYTHON_VERSION_MAJOR}" STREQUAL "2" AND PYTHON_VERSION_STRING VERSION_LESS ${version})
      message(FATAL_ERROR "${CMAKE_PROJECT_NAME} requires at least python ${version}")
    endif()
  else()
    # This is a python3 requirement.
    if("${PYTHON_VERSION_MAJOR}" STREQUAL "3" AND PYTHON_VERSION_STRING VERSION_LESS ${version})
      message(FATAL_ERROR "${CMAKE_PROJECT_NAME} requires at least python ${version}")
    endif()
  endif()
endmacro()


macro(dune_force_python_version version)
  if(NOT "${PYTHON_MAJOR_VERSION}" STREQUAL "${version}")
    message(FATAL_ERROR "${CMAKE_PROJECT_NAME} requires python ${version}!")
  endif()
endmacro()