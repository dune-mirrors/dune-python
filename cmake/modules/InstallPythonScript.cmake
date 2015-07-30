# Macro to install a single executable python script
#
# dune_install_python_script(SCRIPT script [script2 ...]
#                           [MAJOR_VERSION version]
#                           [REQUIRES requ1 [requ2 ...]])
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
# If your script requires any non-dune python packages, pass them via the
# REQUIRES parameter. They will be installed into the virtualenv
# using pip and will be installed on the system during "make install".
# Dune python packages are already present in the virtualenv.
#

function(dune_install_python_script)
  # Parse Arguments
  set(OPTION)
  set(SINGLE MAJOR_VERSION)
  set(MULTI SCRIPT REQUIRES)
  include(CMakeParseArguments)
  cmake_parse_arguments(PYINST "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(PYINST_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in dune_install_python_script: This often indicates typos!")
  endif()

  # apply defaults
  if(NOT PYINST_MAJOR_VERSION)
    set(PYINST_MAJOR_VERSION 2 3)
  endif()

  # check for available pip packages
  check_python_package(PACKAGE pip
                       INTERPRETER ${PYTHON2_EXECUTABLE}
                       RESULT PIP2_FOUND)
  check_python_package(PACKAGE pip
                       INTERPRETER ${PYTHON3_EXECUTABLE}
                       RESULT PIP3_FOUND)

  foreach(version ${PYINST_MAJOR_VERSION})
    # Install the requirements into the virtualenv
    foreach(requ ${PYINST_REQUIRES})
      execute_process(COMMAND ${CMAKE_BINARY_DIR}/dune-env-${version} pip install ${requ})
    endforeach()

    # Install into the virtualenv(s)
    foreach(file ${PYINST_SCRIPT})
      # Write a copy script, this separation is necessary to evaluate the environment variable
      # VIRTUAL_ENV actually inside the virtualenv, not in the scope of the outer cmake run.
      file(WRITE ${CMAKE_BINARY_DIR}/cp.cmake "file(COPY ${file} DESTINATION \$ENV{VIRTUAL_ENV}/bin)")
      execute_process(COMMAND ${CMAKE_BINARY_DIR}/dune-env-${version} ${CMAKE_COMMAND} -P ${CMAKE_BINARY_DIR}/cp.cmake
                      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
      # remove the auxiliary script
      file(REMOVE ${CMAKE_BINARY_DIR}/cp.cmake)
    endforeach()

    # Install the given requirements during make install
    if(PIP${version}_FOUND)
      set(USER_STRING "")
      if(DUNE_PYTHON_INSTALL_USER)
        set(USER_STRING "--user ${DUNE_PYTHON_INSTALL_USER}")
      endif()
      install(CODE "execute_process(COMMAND ${PYTHON${version}_EXECUTABLE} -m pip install ${USER_STRING} ${requ})")
    else()
      install(CODE "message(FATAL_ERROR \"You need the python${version} package pip installed on the host system to install requirements of script ${PYINST_SCRIPT}\")")
    endif()

    # Mark it for global installation
    install(FILES ${PYINST_SCRIPT} DESTINATION ${CMAKE_INSTALL_BINDIR})
  endforeach()
endfunction()
