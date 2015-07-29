# Macros to write wrappers around the virtualenvs created.
#
# create_virtualenv_wrapper(ENVPATH path
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
  set(MULTI)
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

  # use configure_file to actually write a wrapper script
  configure_file(${DUNE_PYTHON_TEMPLATES_PATH}/env-wrapper.${DUNE_PYTHON_SCRIPT_EXT}.in
                 ${ENV_WRAPPER_PATH}/${ENV_WRAPPER_NAME}.${DUNE_PYTHON_SCRIPT_EXT})
endfunction()
