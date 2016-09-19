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
#    .. note::
#       If possible, the preferable way of installing python scripts is
#       defining them in :code:`setup.py` of some package installed with
#       :ref:`dune_install_python_package`. Only if that is not feasible,
#       fall back to this function.
#

function(dune_install_python_script)
  # Parse Arguments
  set(OPTION)
  set(SINGLE)
  set(MULTI SCRIPT REQUIRES)
  include(CMakeParseArguments)
  cmake_parse_arguments(PYINST "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(PYINST_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in dune_install_python_script: This often indicates typos!")
  endif()

  #
  # Install the requirements and the scripts into the virtualenv
  #

  foreach(requ ${PYINST_REQUIRES})
    execute_process(COMMAND ${DUNE_PYTHON_VIRTUALENV_INTERPRETER} -m pip install ${requ}
                    RESULT_VARIABLE retcode)
    if(NOT "${retcode}" STREQUAL "0")
      message(FATAL_ERROR "Fatal error when installing ${requ} as a requirement for ${PYINST_SCRIPT}")
    endif()
  endforeach()

  foreach(file ${PYINST_SCRIPT})
    # Write a copy script, this separation is necessary to evaluate the environment variable
    # VIRTUAL_ENV actually inside the virtualenv, not in the scope of the outer cmake run.
    file(WRITE ${CMAKE_BINARY_DIR}/cp.cmake "file(COPY ${file} DESTINATION \$ENV{VIRTUAL_ENV}/bin)")
    execute_process(COMMAND ${CMAKE_BINARY_DIR}/dune-env ${CMAKE_COMMAND} -P ${CMAKE_BINARY_DIR}/cp.cmake
                    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                    RESULT_VARIABLE retcode)
    if(NOT "${retcode}" STREQUAL "0")
      message(FATAL_ERROR "Fatal error when installing the script ${PYINST_SCRIPT}")
    endif()
    # remove the auxiliary script
    file(REMOVE ${CMAKE_BINARY_DIR}/cp.cmake)
  endforeach()

  #
  # Now define rules for `make install`.
  #

  check_python_package(PACKAGE pip)
  if(DUNE_PYTHON_PIP_FOUND)
    set(USER_STRING "")
    if(DUNE_PYTHON_INSTALL_USER)
      set(USER_STRING "--user")
    endif()

    foreach(requ ${PYINST_REQUIRES})
      install(CODE "execute_process(COMMAND ${PYTHON_EXECUTABLE} -m pip install ${USER_STRING} ${requ}
                                    RESULT_VARIABLE retcode)
                    if(NOT \"${retcode}\" STREQUAL \"0\")
                      message(FATAL_ERROR \"Fatal error when installing ${requ} as a requirement for ${PYINST_SCRIPT}\")
                    endif()"
              )
    endforeach()
  else()
    install(CODE "message(FATAL_ERROR \"You need pip installed on the host system to install requirements of script ${PYINST_SCRIPT}\")")
  endif()

  # Mark the actual scripts for global installation
  install(FILES ${PYINST_SCRIPT} DESTINATION ${CMAKE_INSTALL_BINDIR})
endfunction()
