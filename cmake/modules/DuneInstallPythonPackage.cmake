# This cmake module provides macros that allow to access and modify the virtual env
# that is shared by all dune modules, that depend on dune-python.
#
# dune_install_python_package(PATH path)
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

function(dune_install_python_package)
  # Parse Arguments
  set(OPTION)
  set(SINGLE PATH)
  set(MULTI)
  include(CMakeParseArguments)
  cmake_parse_arguments(PYINST "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(PYINST_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in dune_install_python_packge: This often indicates typos!")
  endif()

  # install the package into the virtual env
  execute_process(COMMAND ${CMAKE_BINARY_DIR}/dune-env.sh pip install -e .
                  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/${PYINST_PATH})

  # define a rule on how to install the package during make install
  if(DUNE_PYTHON_pip_FOUND)
    set(USER_STRING "")
    if(DUNE_PYTHON_INSTALL_USER)
      set(USER_STRING "--user ${DUNE_PYTHON_INSTALL_USER}")
    endif()
    install(CODE "execute_process(COMMAND pip install ${USER_STRING} .
                                  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/${PYINST_PATH})
                 ")
  else()
    install(CODE "message(FATAL_ERROR \"You need pip installed on the host system to install a module that contains python code\")")
  endif()
endfunction()
