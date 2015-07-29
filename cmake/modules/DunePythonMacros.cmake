# include all macros that dune-python offers. They can be documented better if placed
# in cmake modules grouped together by functionality
include(CreateVirtualEnv)
include(DuneInstallPythonPackage)
include(PythonVersion)
include(VirtualEnvWrapper)

# Look for python interpreters. CMake is okay at finding Python2 or Python3,
# but sucks at finding both. We try working around the problem...
find_package(Python3Interp)
find_package(Python2Interp)
if(NOT PYTHON3INTERP_FOUND AND NOT PYTHON2INTERP_FOUND)
  message(FATAL_ERROR "Could not determine the location of your python interpreter")
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
create_virtualenv_wrapper(ENVPATH ${DUNE_VIRTUALENV_PATH}
                          NAME dune-env)
create_virtualenv_wrapper(ENVPATH ${DUNE_VIRTUALENV_PATH}
                          NAME dune-env-2)

# The python3 virtualenv
create_virtualenv(NAME python3-env
                  ONLY_ONCE
                  REAL_PATH DUNE_VIRTUALENV_PATH
                  INTERPRETER ${PYTHON3_EXECUTABLE})
create_virtualenv_wrapper(ENVPATH ${DUNE_VIRTUALENV_PATH}
                          NAME dune-env-3)
