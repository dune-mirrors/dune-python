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

  # install the package
  execute_process(COMMAND ${CMAKE_BINARY_DIR}/dune-env.sh pip install .
                  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/${PYINST_PATH})
endfunction()
