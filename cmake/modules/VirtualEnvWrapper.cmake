# Macros to write wrappers around the virtualenvs created.
#
# create_virtualenv_wrapper(ENVPATH path
#                          [COMMANDS cmd1 cmd2 ...]
#                          [PATH scriptpath]
#                          [NAME name])
#
# Write a wrapper script around the virtualenv located at the
# path given to the ENVPATH argument.
#
# You may set the NAME parameter to manually set the name of
# the wrapper script. Defaults to the name of the virtualenv.
#
# The generated script will be placed in the directory specified
# with the PATH parameter. Defaults to the (root) build directory
# of the current module.
#
# If one or more commands are given those commands will be executed
# pasted before the command string given from the command line.
# Example: passing 'python' as command will create a script that
# opens an interactive interpreter running in the virtualenv.
#
#


# Determine the directory, that the dune-python cmake macros are located
# This actually depends on this module being dune-python itself, or some other
if(CMAKE_PROJECT_NAME STREQUAL dune-python)
  set(DUNE_PYTHON_TEMPLATES_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)
else()
  set(DUNE_PYTHON_TEMPLATES_PATH ${dune-python_MODULE_PATH})
endif()

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

  # use configure_file to actually write a wrapper script
  configure_file(${DUNE_PYTHON_TEMPLATES_PATH}/env-wrapper.${DUNE_PYTHON_SCRIPT_EXT}.in
                 ${ENV_WRAPPER_PATH}/${ENV_WRAPPER_NAME}.${DUNE_PYTHON_SCRIPT_EXT})
endfunction()
