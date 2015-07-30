# Macro to install a single executable python script
#
# dune_install_python_script(SCRIPT script [script2 ...]
#                           [MAJOR_VERSION version])
#
# Installs a script into the virtualenv(s) created by dune-python.
# It is placed in the bin folder of the env. You should write
# your python scripts with a shebang such as:
# #!/usr/bin/env python
# This avoids hardcoding of an interpreter.
#
# This macro also marks the script for global installation.
#
# If your script only works with python2 or with python3, give the number to the
# MAJOR_VERSION parameter. This will restrict the installation process to that
# python version.
#

function(dune_install_python_script)
  # Parse Arguments
  set(OPTION)
  set(SINGLE MAJOR_VERSION)
  set(MULTI SCRIPT)
  include(CMakeParseArguments)
  cmake_parse_arguments(PYINST "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(PYINST_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in dune_install_python_script: This often indicates typos!")
  endif()

  # apply defaults
  if(NOT PYINST_MAJOR_VERSION)
    set(PYINST_MAJOR_VERSION 2 3)
  endif()

  foreach(version ${PYINST_MAJOR_VERSION})
    # Install into the virtualenv(s)
    foreach(file ${PYINST_SCRIPT})
      # copy the file into the virtual env. The copy command is "cmake -E copy"
      execute_process(COMMAND ${CMAKE_BINARY_DIR}/dune-env-${version} ${CMAKE_COMMAND} -E copy ${file} $ENV{VIRTUAL_ENV}/bin)
    endforeach()

    # Mark it for global installation
    install(FILES ${PYINST_SCRIPT} DESTINATION ${CMAKE_INSTALL_BINDIR})
  endforeach()
endfunction()
