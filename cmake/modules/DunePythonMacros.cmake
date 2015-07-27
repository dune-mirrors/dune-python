# include all macros that dune-python offers. They can be documented better if placed
# in cmake modules grouped together by functionality
include(CheckPythonPackage)
include(DuneInstallPythonPackage)
include(PythonVersion)

# The code we do want to execute whenever a module that requires or suggests dune-python is configured
find_package(PythonInterp REQUIRED)
check_python_package(PACKAGE virtualenv)
check_python_package(PACKAGE pip)

# Create a virtualenv to install all python packages from all dune
# modules that provide packages in. We only ever want to create one
# such virtualenv, not one for each module that depends on dune-python.
# This virtualenv needs to be placed in the build directory of the
# first non-installed module in the stack of modules to build.

# First iterate over the list of dependencies and look for virtualenvs
set(DUNE_VIRTUALENV_PATH)
foreach(mod ${${CMAKE_PROJECT_NAME}_DEPENDS} ${${CMAKE_PROJECT_NAME}_SUGGESTS})
  if(IS_DIRECTORY ${${mod}_DIR}/python-env)
    set(DUNE_VIRTUALENV_PATH ${${mod}_DIR}/python-env)
  endif()
  # check in the current build directory - this might be a reconfigure
  if(IS_DIRECTORY ${CMAKE_BINARY_DIR}/python-env)
    set(DUNE_VIRTUALENV_PATH ${CMAKE_BINARY_DIR}/python-env)
  endif()
endforeach()

# If none was found, we need to create a new one.
if(NOT DUNE_VIRTUALENV_PATH)
  if(DUNE_PYTHON_virtualenv_FOUND)
    message("Building a virtual env in ${CMAKE_BINARY_DIR}/python-env...")
    execute_process(COMMAND virtualenv -p ${PYTHON_EXECUTABLE} --system-site-packages ${CMAKE_BINARY_DIR}/python-env)
    set(DUNE_VIRTUALENV_PATH ${CMAKE_BINARY_DIR}/python-env)
  else()
    message(FATAL_ERROR "You do need the python package virtualenv installed to build the module ${CMAKE_PROJECT_NAME} locally!")
  endif()
endif()

# Write a wrapper for the virtualenv into the current build directory
# TODO provide versions of this script that work on other platforms
if(CMAKE_PROJECT_NAME STREQUAL dune-python)
  set(DUNE_PYTHON_TEMPLATES_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)
else()
  set(DUNE_PYTHON_TEMPLATES_PATH ${dune-python_MODULE_PATH})
endif()
configure_file(${DUNE_PYTHON_TEMPLATES_PATH}/env-wrapper.sh.in ${CMAKE_BINARY_DIR}/dune-env.sh)
