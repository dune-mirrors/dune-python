# Macros to write wrappers around the virtualenvs created.
# This is used internally by dune-python to create wrappers.
# You may still use it to create custom wrappers if needed.
#
# .. cmake_function:: create_virtualenv_wrapper
#
#    .. cmake_param:: ENVPATH
#       :single:
#       :required:
#       :argname: path
#
#       Directory that the virtualenv to wrap is located
#
#    .. cmake_param:: COMMANDS
#       :multi:
#
#       The given commands will be pasted before the command
#       string given from the command line. Example: passing
#       :code:`python` as command will create a script that
#       opens an interactive interpreter running in the virtualenv.
#
#    .. cmake_param:: PATH
#       :single:
#
#       Directory to place the generated script in.
#       Defaults to the (root) build directory of the current module.
#
#    .. cmake_param: NAME
#       :single:
#
#       The name of the wrapper script. Defaults to the name of
#       the virtualenv.
#


# TODO: Check the type of system we are operating on here and choose
# an extension for wrapper templates accordingly.
set(DUNE_PYTHON_SCRIPT_EXT sh)

function(create_virtualenv_wrapper)
  # Parse Arguments
  set(OPTION)
  set(SINGLE ENVPATH PATH NAME)
  set(MULTI COMMANDS)
  include(CMakeParseArguments)
  cmake_parse_arguments(ENV_WRAPPER "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(ENV_WRAPPER_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in create_virtualenv_wrapper: This often indicates typos!")
  endif()

  # apply defaults
  if(NOT ENV_WRAPPER_NAME)
    # Use get_filename_component to extract the last directory in the path.
    # First step is necessary to be robust towards a / being at the end of the input.
    get_filename_component(split "${ENV_WRAPPER_ENVPATH}/dummy.file" DIRECTORY)
    get_filename_component(split ${split} NAME)
    set(ENV_WRAPPER_NAME ${split})
  endif()
  if(NOT ENV_WRAPPER_PATH)
    set(ENV_WRAPPER_PATH ${CMAKE_BINARY_DIR})
  endif()

  # set the variables for substitution in the wrapper script
  set(DUNE_VIRTUALENV_COMMANDS "")
  foreach(command ${ENV_WRAPPER_COMMANDS})
    set(DUNE_VIRTUALENV_COMMANDS "${DUNE_VIRTUALENV_COMMANDS} ${command}")
  endforeach()
  set(DUNE_VIRTUALENV_PATH ${ENV_WRAPPER_ENVPATH})

  # Write a message about generating the script.
  message("-- Writing a wrapper script around virtualenv to ${ENV_WRAPPER_PATH}/${ENV_WRAPPER_NAME}")

  # Get the dune-python module path for the template
  dune_module_path(MODULE dune-python
                   RESULT DUNE_PYTHON_TEMPLATES_PATH
                   CMAKE_MODULES)

  # use configure_file to actually write a wrapper script
  configure_file(${DUNE_PYTHON_TEMPLATES_PATH}/env-wrapper.${DUNE_PYTHON_SCRIPT_EXT}.in
                 ${ENV_WRAPPER_PATH}/${ENV_WRAPPER_NAME})
endfunction()
