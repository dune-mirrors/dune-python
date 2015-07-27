# This cmake module provides macros that allow to access and modify the virtual env
# that is shared by all dune modules, that depend on dune-python.
#
# dune_install_python_package(PATH path
#                             MAJOR_VERSION version)
#
# Installs the python package located at path into the virtualenv used by dune-python
# The package at the given location is expected to be a pip installable package.
# Also marks the given python package for global installation during "make install".
# By default, the python package will then be installed into the system-wide site-packages
# location. If you do not want to install it there, or you do not have permission to,
# you may optionally set the DUNE_PYTHON_INSTALL_USER parameter to a username. The
# packages will then be installed in the home directory of that user.
# This is done through pips --user option. Installation in arbitrary locations is not
# supported to minimize PYTHONPATH issues.
#
# If your package only works with python2 or with python3, give the number to the
# MAJOR_VERSION parameter. This will restrict the installation process to that
# python version.

function(dune_install_python_package)
  # Parse Arguments
  set(OPTION)
  set(SINGLE PATH MAJOR_VERSION)
  set(MULTI)
  include(CMakeParseArguments)
  cmake_parse_arguments(PYINST "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(PYINST_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in dune_install_python_package: This often indicates typos!")
  endif()

  # apply defaults
  if(NOT PYINST_MAJOR_VERSION)
    set(PYINST_MAJOR_VERSION 2 3)
  endif()

  # iterate over the given interpreters
  foreach(version ${PYINST_MAJOR_VERSION})
    # install the package into the virtual env
    execute_process(COMMAND ${CMAKE_BINARY_DIR}/dune-env-${version}.sh pip install -e .
                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/${PYINST_PATH})

    # define a rule on how to install the package during make install
    if(DUNE_PYTHON${version}_pip_FOUND)
      set(USER_STRING "")
      if(DUNE_PYTHON_INSTALL_USER)
        set(USER_STRING "--user ${DUNE_PYTHON_INSTALL_USER}")
      endif()
      install(CODE "execute_process(COMMAND pip${version} install ${USER_STRING} .
                                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/${PYINST_PATH})
                   ")
    else()
      install(CODE "message(FATAL_ERROR \"You need pip${version} installed on the host system to install a module that contains python code\")")
    endif()
  endforeach()
endfunction()
