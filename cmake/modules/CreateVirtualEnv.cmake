# The macro that actually creates the virtualenv. May be used to create
# custom virtualenvs out of cmake if needed, but meant for internal usage
# mainly.
#
# create_virtualenv(NAME name
#                  [PATH path]
#                  [REAL_PATH real_path]
#                  [ONLY_ONCE]
#                  [INTERPRETER interpreter])
#
# This creates a virtualenv in the directory path/name, where path
# defaults to the root of the current build directory.
# The python interpreter running in the virtualenv may be set through
# the INTERPRETER parameter. If not set, it defaults to PYTHON2_EXECUTABLE.
#
# If the ONLY_ONCE parameter is set, cmake will look through all
# build directories in the set of modules this module depends on
# and only create a virtualenv, if no virtualenv has been created yet.
#
# The variable given to REAL_PATH will point to the requested virtualenv,
# even if it is located in a different module.
#

function(create_virtualenv)
  # Parse Arguments
  set(OPTION ONLY_ONCE)
  set(SINGLE PATH NAME REAL_PATH INTERPRETER)
  set(MULTI)
  include(CMakeParseArguments)
  cmake_parse_arguments(CREATE_ENV "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(CREATE_ENV_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in check_python_package: This often indicates typos!")
  endif()

  # apply defaults
  if(NOT CREATE_ENV_INTERPRETER)
    set(CREATE_ENV_INTERPRETER ${PYTHON2_EXECUTABLE})
  endif()
  if(NOT CREATE_ENV_PATH)
    set(CREATE_ENV_PATH ${CMAKE_BINARY_DIR})
  endif()

  # check whether a virtualenv that matches our need already accepts
  if(CREATE_ENV_ONLY_ONCE)
    # First iterate over the list of dependencies and look for virtualenvs
    set(VIRTUALENV_PATH)
    foreach(mod ${${CMAKE_PROJECT_NAME}_DEPENDS} ${${CMAKE_PROJECT_NAME}_SUGGESTS})
      if(IS_DIRECTORY ${${mod}_DIR}/${CREATE_ENV_NAME})
        set(VIRTUALENV_PATH ${${mod}_DIR}/${CREATE_ENV_NAME})
      endif()
      # check in the current build directory - this might be a reconfigure
      if(IS_DIRECTORY ${CMAKE_BINARY_DIR}/${CREATE_ENV_NAME})
        set(VIRTUALENV_PATH ${CMAKE_BINARY_DIR}/${CREATE_ENV_NAME})
      endif()
    endforeach()
  endif()

  # create virtualenv oly if really needed
  if(NOT CREATE_ENV_ONLY_ONCE OR NOT VIRTUALENV_PATH)
    if(PYTHON2INTERP_FOUND AND DUNE_PYTHON2_virtualenv_FOUND)
      message("Building a virtual env in ${CMAKE_BINARY_DIR}/${CREATE_ENV_NAME}...")
      execute_process(COMMAND virtualenv -p ${CREATE_ENV_INTERPRETER} --system-site-packages ${CREATE_ENV_PATH}/${CREATE_ENV_NAME})
      set(VIRTUALENV_PATH ${CREATE_ENV_PATH}/${CREATE_ENV_NAME})
    else()
      message(FATAL_ERROR "You do need the python2 package virtualenv installed to build the module ${CMAKE_PROJECT_NAME} locally!")
    endif()
  endif()

  # Set the path to the virtualenv in the outer scope
  set(${CREATE_ENV_REAL_PATH} ${VIRTUALENV_PATH} PARENT_SCOPE)
endfunction()
