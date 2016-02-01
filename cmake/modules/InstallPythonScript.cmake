# Macro to install a single executable python script into
# the dune-python virtualenv.
#
# .. cmake_function:: dune_install_python_script
#
#    .. cmake_param:: SCRIPT
#       :multi:
#       :required:
#
#       The script(s) to install into the virtualenv.
#
#    .. cmake_param:: MAJOR_VERSION
#       :single:
#       :argname: version
#
#       Set to "2" or "3" if your python package only works with
#       python2 or python3. This will restrict the installation process to that
#       python version.
#
#    .. cmake_param:: REQUIRES
#       :multi:
#       :argname: requ
#
#       List any non-dune python packages, that your script requires.
#       Those packages will be installed into the virtualenv and on
#       the system during :code:`make install` using `pip`.
#
#    Installs a script into the virtualenv(s) created by dune-python.
#    It is placed in the bin folder of the env. You should write
#    your python scripts with a shebang such as:
#
#    :code:`#!/usr/bin/env python`
#
#    This avoids hardcoding of an interpreter.
#
#    This macro also marks the script for global installation.
#    For details on the dune-python virtualenv concept see :ref:`virtualenv`.
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
      execute_process(COMMAND ${CMAKE_BINARY_DIR}/dune-env-${version} pip install --ignore-installed ${requ}
                      RESULT_VARIABLE retcode)
      if(NOT "${retcode}" STREQUAL "0")
        message(FATAL_ERROR "Fatal error when installing ${requ} as a requirement for ${PYINST_SCRIPT}")
      endif()
    endforeach()

    # Install into the virtualenv(s)
    foreach(file ${PYINST_SCRIPT})
      # Write a copy script, this separation is necessary to evaluate the environment variable
      # VIRTUAL_ENV actually inside the virtualenv, not in the scope of the outer cmake run.
      file(WRITE ${CMAKE_BINARY_DIR}/cp.cmake "file(COPY ${file} DESTINATION \$ENV{VIRTUAL_ENV}/bin)")
      execute_process(COMMAND ${CMAKE_BINARY_DIR}/dune-env-${version} ${CMAKE_COMMAND} -P ${CMAKE_BINARY_DIR}/cp.cmake
                      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                      RESULT_VARIABLE retcode)
      if(NOT "${retcode}" STREQUAL "0")
        message(FATAL_ERROR "Fatal error when installing the script ${PYINST_SCRIPT}")
      endif()
      # remove the auxiliary script
      file(REMOVE ${CMAKE_BINARY_DIR}/cp.cmake)
    endforeach()

    # Install the given requirements during make install
    if(PIP${version}_FOUND)
      set(USER_STRING "")
      if(DUNE_PYTHON_INSTALL_USER)
        set(USER_STRING "--user")
      endif()
      foreach(requ ${PYINST_REQUIRES})
        install(CODE "message(\"dune-python runs this install command: ${PYTHON${version}_EXECUTABLE} ${SYSTEM_INSTALL_OPTIONS}\")
                      execute_process(COMMAND ${PYTHON${version}_EXECUTABLE} -m pip install ${USER_STRING} ${requ}
                                      RESULT_VARIABLE retcode)
                      if(NOT \"${retcode}\" STREQUAL \"0\")
                        message(FATAL_ERROR \"Fatal error when installing ${requ} as a requirement for ${PYINST_SCRIPT}\")
                      endif()"
                )
      endforeach()
    else()
      install(CODE "message(FATAL_ERROR \"You need the python${version} package pip installed on the host system to install requirements of script ${PYINST_SCRIPT}\")")
    endif()

    # Mark it for global installation
    install(FILES ${PYINST_SCRIPT} DESTINATION ${CMAKE_INSTALL_BINDIR})
  endforeach()
endfunction()
