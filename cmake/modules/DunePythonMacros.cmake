# .. cmake_module::
#
#    The cmake code to execute whenever a module requires or suggests dune-python.
#
#    A summary of what is done:
#
#    * All cmake modules from dune-python are included. This allows usage of
#      dune-python without taking care of module inclusion.
#    * The python interpreter in use for this project is determined. This
#      may even be an interpreter from a virtualenv.
#    * A virtualenv is created. This virtualenv is shared between all dune modules.
#      Wrappers to activate the virtualenv are placed in every build directory.
#      Check :ref:`virtualenv` for details.
#
# .. cmake_variable:: DUNE_FORCE_PYTHON2
#
#     Set this variable to TRUE to force usage of a python2 interpreter. This is
#     the *user-facing* interface, developers of Dune modules, may force the python
#     major version through :ref:`dune_force_python_version`.
#
#     .. note::
#        This does not check for the interpreter requirements of your python packages.
#        If you set it and one of your packages requires python2, you will get an error.
#
#
# .. cmake_variable:: DUNE_FORCE_PYTHON3
#
#     Set this variable to TRUE to force usage of a python3 interpreter. This is
#     the *user-facing* interface, developers of Dune modules, may force the python
#     major version through :ref:`dune_force_python_version`.
#
#     .. note::
#        This does not check for the interpreter requirements of your python packages.
#        If you set it and one of your packages requires python2, you will get an error.
#

# Define the location of the Dune wheelhouse
set(DUNE_PYTHON_WHEELHOUSE ${CMAKE_INSTALL_PREFIX}/share/dune/python/wheelhouse)

# Add python related metatargets
add_custom_target(pytest)
add_custom_target(pyinstall)

# include all macros that dune-python offers. They can be documented better if placed
# in cmake modules grouped together by functionality
include(CreateVirtualEnv)
include(DuneExecuteProcess)
include(DunePathHelper)
include(DunePythonTesting)
include(DuneSphinxCMakeDoc)
include(InstallPythonPackage)
include(InstallPythonScript)
include(PythonVersion)
include(VirtualEnvWrapper)

# Also set some variables and includes in the installation script
install(CODE "set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH})
              set(DUNE_PYTHON_WHEELHOUSE ${DUNE_PYTHON_WHEELHOUSE})
              include(DuneExecuteProcess)
             ")

# Nuke any python interpreter found by dune-common from the cache.
# It did not use our constraints!
unset(PYTHON_EXECUTABLE CACHE)
set(PYTHONINTERP_FOUND FALSE)

# Look for the python interpreter. Note that this interpreter might also be
# originating from a virtual environment.
set(_VERSION_STRING "")
if(DUNE_FORCE_PYTHON2 AND DUNE_FORCE_PYTHON3)
  message(FATAL_ERROR "Cannot enforce both python2 *and* python3")
endif()
if(DUNE_FORCE_PYTHON2)
  set(_VERSION_STRING "2")
endif()
if(DUNE_FORCE_PYTHON3)
  set(_VERSION_STRING "3")
endif()
find_package(PythonInterp ${_VERSION_STRING} REQUIRED)

# Look for additional software, such as Sphinx
find_package(Sphinx)

# Create a virtualenv to install all python packages from all dune
# modules that provide packages in. We only ever want to create one
# such virtualenv, not one for each module that depends on dune-python.
# This virtualenv needs to be placed in the build directory of the
# first non-installed module in the stack of modules to build.

create_virtualenv(NAME python-env
                  ONLY_ONCE)

# We also create a wrapper around this virtual env, which is placed
# in every build directory for easy access without knowledge of the
# actual location of the env.
create_virtualenv_wrapper(ENVPATH ${DUNE_PYTHON_VIRTUALENV_PATH}
                          NAME dune-env)

# During `make install`, also install all python stuff
install(CODE "message(\"Installing python packages defined in ${CMAKE_PROJECT_NAME}...\")
              dune_execute_process(COMMAND ${CMAKE_COMMAND} --build . --target pyinstall)")
