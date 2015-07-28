# include all macros that dune-python offers. They can be documented better if placed
# in cmake modules grouped together by functionality
include(CheckPythonPackage)
include(CreateVirtualEnv)
include(DuneInstallPythonPackage)
include(PythonVersion)

# Look for python interpreters. CMake is okay at finding Python2 or Python3,
# but sucks at finding both. We try working around the problem...
find_package(Python3Interp)
find_package(Python2Interp)
if(NOT PYTHON3INTERP_FOUND AND NOT PYTHON2INTERP_FOUND)
  message(FATAL_ERROR "Could not determine the location of your python interpreter")
endif()

# Look for python packages that we need on the host system
check_python_package(PACKAGE virtualenv)
check_python_package(PACKAGE pip)

# Determine the directory, that the dune-python cmake macros are located
# This actually depends on this module being dune-python itself, or some other
if(CMAKE_PROJECT_NAME STREQUAL dune-python)
  set(DUNE_PYTHON_TEMPLATES_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)
else()
  set(DUNE_PYTHON_TEMPLATES_PATH ${dune-python_MODULE_PATH})
endif()

# Create a virtualenv to install all python packages from all dune
# modules that provide packages in. We only ever want to create one
# such virtualenv, not one for each module that depends on dune-python.
# This virtualenv needs to be placed in the build directory of the
# first non-installed module in the stack of modules to build.

# The python2 virtualenv
create_virtualenv(NAME python2-env
                  ONLY_ONCE
                  REAL_PATH DUNE_VIRTUALENV_PATH)
configure_file(${DUNE_PYTHON_TEMPLATES_PATH}/env-wrapper.sh.in ${CMAKE_BINARY_DIR}/dune-env.sh)
configure_file(${DUNE_PYTHON_TEMPLATES_PATH}/env-wrapper.sh.in ${CMAKE_BINARY_DIR}/dune-env-2.sh)

# The python3 virtualenv
create_virtualenv(NAME python3-env
                  ONLY_ONCE
                  REAL_PATH DUNE_VIRTUALENV_PATH
                  INTERPRETER ${PYTHON3_EXECUTABLE})
configure_file(${DUNE_PYTHON_TEMPLATES_PATH}/env-wrapper.sh.in ${CMAKE_BINARY_DIR}/dune-env-3.sh)
