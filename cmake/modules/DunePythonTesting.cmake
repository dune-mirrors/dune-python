# Support for python testing frameworks.
#
# .. cmake_function:: add_python_test_command
#
#    .. cmake_param:: COMMAND
#       :multi:
#       :required:
#
#       The command to run during :code:`make pytest`.
#
#    .. cmake_param:: WORKING_DIRECTORY
#       :single:
#       :argname: dir
#
#       The working directory of the command. Defaults to
#       the current build directory.
#
#    .. cmake_param:: REQUIRED_PACKAGES
#       :multi:
#
#       A list of python packages that are needed for this test command.
#       They will be installed into the virtualenv.
#
#    Integrates a python testing framework command into the Dune
#    build system. Added commands are run, when the target
#    :code:`pytest` is built.
#

function(add_python_test_command)
  # Parse Arguments
  set(OPTION)
  set(SINGLE WORKING_DIRECTORY VIRTUALENV)
  set(MULTI COMMAND REQUIRED_PACKAGES)
  include(CMakeParseArguments)
  cmake_parse_arguments(PYTEST "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(PYTEST_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in add_python_test_command: This often indicates typos!")
  endif()

  # Apply defaults
  if(NOT PYTEST_WORKING_DIRECTORY)
    set(PYTEST_WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
  endif()
  if(NOT PYTEST_VIRTUALENV)
    set(PYTEST_VIRTUALENV ${CMAKE_BINARY_DIR}/dune-env)
  endif()

  # Extend the given virtualenv to be a full path.
  if(NOT IS_ABSOLUTE ${PYTEST_VIRTUALENV})
    set(PYTEST_VIRTUALENV ${CMAKE_BINARY_DIR}/${PYTEST_VIRTUALENV})
  endif()

  if(PYTEST_REQUIRED_PACKAGES)
    dune_execute_process(COMMAND ${DUNE_PYTHON_VIRTUALENV_INTERPRETER} -m pip install ${PYTEST_REQUIRED_PACKAGES}
                         ERROR_MESSAGE "Error installing dependencies of testing command")
  endif()

  # Get a string unique to this testing command to name the target
  set(commandstr "")
  foreach(comm ${PYTEST_COMMAND})
    set(commandstr "${commandstr}_${comm}")
  endforeach()
  set(commandstr "${commandstr}_${PYTEST_WORKING_DIRECTORY}")
  string(REPLACE "/" "_" commandstr ${commandstr})

  # extract the raw envwrapper name for the naming scheme of the test target
  get_filename_component(envname ${PYTEST_VIRTUALENV} NAME)

  # Actually run the command
  add_custom_target(pytest_${envname}${commandstr}
                    COMMAND ${PYTEST_VIRTUALENV} ${PYTEST_COMMAND}
                    WORKING_DIRECTORY ${PYTEST_WORKING_DIRECTORY})

  # Build this during make pytest
  add_dependencies(pytest pytest_${envname}${commandstr})
endfunction()
