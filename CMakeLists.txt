cmake_minimum_required(VERSION 2.8.6)
project(dune-python CXX)

if(NOT (dune-common_DIR OR dune-common_ROOT OR
      "${CMAKE_PREFIX_PATH}" MATCHES ".*dune-common.*"))
    string(REPLACE  ${CMAKE_PROJECT_NAME} dune-common dune-common_DIR
      ${PROJECT_BINARY_DIR})
endif()

#find dune-common and set the module path
find_package(dune-common REQUIRED)
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules"
  ${dune-common_MODULE_PATH})

#include the dune macros
include(DuneMacros)

# start a dune project with information from dune.module
dune_project()

# Build a virtual env in the build directory of dune-python
# Downstream modules may install their packages into that
# env and use it through the provided cmake modules and through
# exported scripts.
message("Building a virtual env in ${CMAKE_BINARY_DIR}/python-env...")
execute_process(COMMAND virtualenv -p ${PYTHON_EXECUTABLE} ${CMAKE_BINARY_DIR}/python-env)

add_subdirectory("doc")
add_subdirectory("cmake/modules")

# finalize the dune project, e.g. generating config.h etc.
finalize_dune_project(GENERATE_CONFIG_H_CMAKE)
