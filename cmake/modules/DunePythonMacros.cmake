# The cmake code to execute whenever a module requires or suggests dune-python.
#
# A summary of what is done:
#
# * All cmake modules from dune-python are included. This allows usage of
#   dune-python without taking care of module inclusion.
# * The python2 and python3 interpreters on the host system are searched
# * For both the python2 and python3 interpreter, a virtualenv is created.
#   This virtualenv is shared between all dune modules. Wrappers to activate
#   the virtualenv are placed in every build directory. Check :ref:`virtualenv`
#   for details
#

# do some checks on the given operating system
include(CheckUbuntu)

# include all macros that dune-python offers. They can be documented better if placed
# in cmake modules grouped together by functionality
include(CreateVirtualEnv)
include(DunePythonTesting)
include(InstallPythonPackage)
include(InstallPythonScript)
include(PythonVersion)
include(VirtualEnvWrapper)

# Look for python interpreters. CMake is okay at finding Python2 or Python3,
# but sucks at finding both. We try working around the problem...
find_package(Python3Interp)
find_package(Python2Interp)
if(NOT PYTHON3INTERP_FOUND AND NOT PYTHON2INTERP_FOUND)
  message(FATAL_ERROR "Could not determine the location of your python interpreter")
endif()
# To not mess around with upstream packages looking for python, run the original test once.
find_package(PythonInterp)

# Create a virtualenv to install all python packages from all dune
# modules that provide packages in. We only ever want to create one
# such virtualenv, not one for each module that depends on dune-python.
# This virtualenv needs to be placed in the build directory of the
# first non-installed module in the stack of modules to build.

# The python2 virtualenv
if(PYTHON2INTERP_FOUND)
  create_virtualenv(NAME python2-env
                    ONLY_ONCE
                    REAL_PATH DUNE_PYTHON_VIRTUALENV_PATH)
  create_virtualenv_wrapper(ENVPATH ${DUNE_PYTHON_VIRTUALENV_PATH}
                            NAME dune-env-2)
  create_virtualenv_wrapper(ENVPATH ${DUNE_PYTHON_VIRTUALENV_PATH}
                            NAME dune-env)
#  create_virtualenv_wrapper(ENVPATH ${DUNE_PYTHON_VIRTUALENV_PATH}
#                            COMMANDS python
#                            NAME python2)
#  create_virtualenv_wrapper(ENVPATH ${DUNE_PYTHON_VIRTUALENV_PATH}
#                            COMMANDS python
#                            NAME python)
endif()

# The python3 virtualenv
if(PYTHON3INTERP_FOUND)
  create_virtualenv(NAME python3-env
                    ONLY_ONCE
                    REAL_PATH DUNE_PYTHON_VIRTUALENV_PATH
                    INTERPRETER ${PYTHON3_EXECUTABLE})
  create_virtualenv_wrapper(ENVPATH ${DUNE_PYTHON_VIRTUALENV_PATH}
                            NAME dune-env-3)
  # overwriting the 'dune-env' script from above defines the default to python3
  create_virtualenv_wrapper(ENVPATH ${DUNE_PYTHON_VIRTUALENV_PATH}
                            NAME dune-env)
#  create_virtualenv_wrapper(ENVPATH ${DUNE_PYTHON_VIRTUALENV_PATH}
#                            COMMANDS python
#                            NAME python2)
#  # overwriting the 'python' script from above defines the default to python3
#  create_virtualenv_wrapper(ENVPATH ${DUNE_PYTHON_VIRTUALENV_PATH}
#                            COMMANDS python
#                            NAME python)
endif()
