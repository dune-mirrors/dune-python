# This module provides macros related to different versions of the python interpreter.
#
# dune_require_python_version(version)
# 
# Error out, if the python interpreter found by cmake is older than the given version.

macro(dune_require_python_version version)
  if(PYTHON_VERSION_STRING VERSION_LESS ${version})
    message(FATAL_ERROR "${CMAKE_PROJECT_NAME} requires at least python ${version}")
  endif()
endmacro()

