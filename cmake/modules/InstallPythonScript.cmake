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
#       List any python packages, that your script requires.
#       Those packages will be installed into the virtualenv and on
#       the system during :code:`make install` using `pip`.
#
#    This function installs the given scripts. It
#
#    * installs it inside the dune-python virtualenv at configure time
#    * installs it into the environment of the found python interpreter during
#      :code:`make pyinstall` and during :code:`make install`.
#
#    You should write your python scripts with a shebang such as:
#
#    :code:`#!/usr/bin/env python`
#
#    This avoids hardcoding of an interpreter.
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

  # Construct the installation command strings from the given options
  set(WHEEL_ARG "")
  if(IS_DIRECTORY ${DUNE_PYTHON_WHEELHOUSE})
    set(WHEEL_ARG "--find-links=${DUNE_PYTHON_WHEELHOUSE}")
  endif()

  foreach(requ ${PYINST_REQUIRES})
    dune_execute_process(COMMAND ${DUNE_PYTHON_VIRTUALENV_INTERPRETER} -m pip install ${WHEEL_ARG} ${requ}
                         ERROR_MESSAGE "Fatal error when installing ${requ} as a requirement for ${PYINST_SCRIPT}"
                         )
  endforeach()

  foreach(file ${PYINST_SCRIPT})
    # Write a copy script, this separation is necessary to evaluate the environment variable
    # VIRTUAL_ENV actually inside the virtualenv, not in the scope of the outer cmake run.
    file(WRITE ${CMAKE_BINARY_DIR}/cp.cmake "file(COPY ${file} DESTINATION \$ENV{VIRTUAL_ENV}/bin)")
    dune_execute_process(COMMAND ${CMAKE_BINARY_DIR}/dune-env ${CMAKE_COMMAND} -P ${CMAKE_BINARY_DIR}/cp.cmake
                         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                         ERROR_MESSAGE "Fatal error when installing the script ${PYINST_SCRIPT}"
                         )
    # remove the auxiliary script
    file(REMOVE ${CMAKE_BINARY_DIR}/cp.cmake)
  endforeach()

  #
  # Now define rules for `make pyinstall`.
  #

  dune_module_path(MODULE dune-python
                   RESULT DUNE_PYTHON_MODULE_DIR
                   CMAKE_MODULES)

  set(USER_STRING "")
  if(DUNE_PYTHON_INSTALL_USER)
    set(USER_STRING "--user")
  endif()

  # First install all requirements
  foreach(requ ${PYINST_REQUIRES})
    # Get a unique name for this target
    string(REPLACE "/" "_" scripts_suffix ${PYINST_SCRIPT})
    string(REPLACE ";" "_" scripts_suffix ${scripts_suffix})
    set(targetname "pyinstall_${scripts_suffix}_${requ}")

    # Construct the command line to install this requirement
    set(SYSTEM_INSTALL_CMDLINE ${PYTHON_EXECUTABLE} -m pip install ${USER_STRING} ${WHEEL_ARG} ${requ})

    # Add a custom target that globally installs this package if requested
    add_custom_target(${targetname}
                      COMMAND ${CMAKE_COMMAND}
                             -DCMAKE_MODULE_PATH=${DUNE_PYTHON_MODULE_DIR}
                             -DCMDLINE="${SYSTEM_INSTALL_CMDLINE}"
                             -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
                             -P ${DUNE_PYTHON_MODULE_DIR}/install_python_package.cmake
                      COMMENT "Installing the python package ${requ} as requirement of ${PYINST_SCRIPT}"
                     )

    add_dependencies(pyinstall ${targetname})
  endforeach()

  # Determine the directory of the current interpreter
  get_filename_component(INST_DIR ${PYTHON_EXECUTABLE} DIRECTORY)

  # Mark the actual scripts for global installation during make pyinstall
  foreach(script ${PYINST_SCRIPT})
    # Get a unique name for this scripts' target
    set(targetname "pyinstall_${script}")

    # Add a custom target that globally installs this script if requested
    add_custom_target(${targetname}
                      COMMAND ${CMAKE_COMMAND} -E copy ${script} ${INST_DIR}
                      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                      COMMENT "Globally installing the python script ${script}"
                     )

    add_dependencies(pyinstall ${targetname})
  endforeach()
endfunction()
