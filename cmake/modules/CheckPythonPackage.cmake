# Find a given python package on the host system. Note, that you should
# only use this macro in the context of dune-python if you really need the
# package to be present on the host. Any dependencies of your python packages
# will instead be installed into the dune-python virtualenv. dune-python
# uses this module to check for the existence of the virtualenv and pip packages.
#
# check_python_package(PACKAGE package
#                     [RESULT result_var]
#                     [INTERPRETER interpreter]
#                     [REQUIRED])
#
# Checks for the existence of the given package on the host system. The variable
# result_var specified by the RESULT parameter will be set correctly afterwards.
# If omitted, the variable DUNE_PYTHON_<package>_FOUND will be set.
#
# If the INTERPRETER option is set the given interpreters search paths will be
# used for the package. If you use this option, you should also specify the RESULT
# parameter to avoid conflicts. Giving an invalid interpreter will result in the
# result to be set to false.
#
# If the REQUIRED option is set, the function will error out if the package is not
# found.

function(check_python_package)
  # Parse Arguments
  set(OPTION REQUIRED)
  set(SINGLE PACKAGE RESULT INTERPRETER)
  set(MULTI)
  include(CMakeParseArguments)
  cmake_parse_arguments(PYCHECK "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(PYCHECK_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in check_python_package: This often indicates typos!")
  endif()

  # apply defaults
  if(NOT PYCHECK_INTERPRETER)
    if(PYTHON3_EXECUTABLE)
      set(PYCHECK_INTERPRETER ${PYTHON3_EXECUTABLE})
    else()
      set(PYCHECK_INTERPRETER ${PYTHON2_EXECUTABLE})
    endif()
  endif()
  if(NOT PYCHECK_RESULT)
    set(PYCHECK_RESULT DUNE_PYTHON_${PYCHECK_PACKAGE}_FOUND)
  endif()

  # Do the actual check
  execute_process(COMMAND ${PYCHECK_INTERPRETER} -c "import ${PYCHECK_PACKAGE}" 
                  RESULT_VARIABLE PYCHECK_RETURN
                  ERROR_QUIET)
  if(PYCHECK_RETURN STREQUAL "0")
    set(${PYCHECK_RESULT} TRUE PARENT_SCOPE)
  else()
    set(${PYCHECK_RESULT} FALSE PARENT_SCOPE)
    if(PYCHECK_REQUIRED)
      message(FATAL_ERROR "The python package ${PYCHECK_PACKAGE} could not be found on the host system! (for interpreter ${PYCHECK_INTERPRETER})")
    endif()
  endif()
endfunction()
