# This cmake module provides macros that allow to access and modify the virtual env
# that is shared by all dune modules, that depend on dune-python.
#
# dune_install_python_package(PATH path)
#
# Installs the python package located at path into the virtualenv used by dune-python
# The package at the given location is expected to be a pip installable package.
# TODO: also install it globally during make install.
#

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
  if(DUNE_PYTHON_PIP_FOUND)
    install(CODE "execute_process(COMMAND pip install .
                                  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/${PYINST_PATH})
                 ")
  else()
    install(CODE "message(FATAL_ERROR \"You need pip installed on the host system to install a module that contains python code\")")
  endif()
endfunction()
