# This module provides macros related to different versions of the python interpreter.
#
# dune_require_python_version(version)
# 
# Error out, if the python interpreter found by cmake is older than the given version.
# Python2 and Pyhton3 versions are not compared to each other, so you can call this
# macro multiple times to enforce minimal versions on a python2 and python3 interpreter
# independently.
#

macro(dune_require_python_version version)
  string(REPLACE "." ";" versionlist ${version})
  list(GET versionlist 0 major)
  if("${major}" STREQUAL "2")
    # This is a python2 requirement.
    if(PYTHON2INTERP_FOUND AND PYTHON2_VERSION_STRING VERSION_LESS ${version})
      message(FATAL_ERROR "${CMAKE_PROJECT_NAME} requires at least python ${version}")
    endif()
  else()
    # This is a python3 requirement.
    if(PYTHON3INTERP_FOUND AND PYTHON3_VERSION_STRING VERSION_LESS ${version})
      message(FATAL_ERROR "${CMAKE_PROJECT_NAME} requires at least python ${version}")
    endif()
  endif()
endmacro()

