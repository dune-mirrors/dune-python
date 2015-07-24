# include all macros that dune-python offers. They can be documented better if placed
# in cmake modules grouped together by functionality
include(CheckPythonPackage)
include(DuneVirtualEnv)
include(PythonVersion)

# The code we do want to execute whenever a module that requires or suggests dune-pyhton is configured
find_package(PythonInterp REQUIRED)
check_python_package(PACKAGE virtualenv REQUIRED)

# Write a wrapper for the virtualenv into the current build directory
# TODO provide versions of this script that work on other platforms
if(CMAKE_PROJECT_NAME STREQUAL dune-python)
  set(DUNE_VIRTUALENV_PATH ${CMAKE_BINARY_DIR}/python-env)
  set(DUNE_PYTHON_TEMPLATES_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)
else()
  set(DUNE_VIRTUALENV_PATH ${dune-python_DIR}/python-env)
  set(DUNE_PYTHON_TEMPLATES_PATH ${dune-python_MODULE_PATH})
endif()
configure_file(${DUNE_PYTHON_TEMPLATES_PATH}/env-wrapper.sh.in ${CMAKE_BINARY_DIR}/dune-env.sh)
