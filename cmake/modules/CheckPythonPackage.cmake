# This module provides functions to check for the existence of
# certain python packages on the host system.
#
# .. cmake_function:: check_python_package
#
#    .. cmake_param:: PACKAGE
#       :required:
#       :single:
#
#       The package name to look for.
#
#    .. cmake_param: RESULT
#       :single:
#
#       The variable to store the result of the check in
#       in the calling scope. Defaults to DUNE_PYTHON_<package>_FOUND
#       Note that the package name is case sensitive and will
#       usually be lowercase.
#
#    .. cmake_param:: INTERPRETER
#       :single:
#
#       If set, the given interpreters search paths will be
#       used for the package. If you use this option, you should also
#       specify the RESULT parameter to avoid conflicts. Giving an
#       invalid interpreter will result in the result to be set to false.
#       Defaults to the found Python3 interpreter if present and the
#       found Python2 interpreter otherwise.
#
#    .. cmake_param:: REQUIRED
#       :option:
#
#       If  set, the function will error out if the package is not
#       found.
#
#
#    Find a given python package on the host system. Note, that you should
#    only use this macro in the context of dune-python if you really need the
#    package to be present on the host. Any dependencies of your python packages
#    will instead be installed into the dune-python virtualenv. dune-python
#    uses this module to check for the existence of the virtualenv and pip packages.

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
    message("Checking for presence of package ${PYCHECK_PACKAGE} with interpreter ${PYCHECK_INTERPRETER}... found!")
  else()
    set(${PYCHECK_RESULT} FALSE PARENT_SCOPE)
    message("Checking for presence of package ${PYCHECK_PACKAGE} with interpreter ${PYCHECK_INTERPRETER}... not found!")
    if(PYCHECK_REQUIRED)
      message(FATAL_ERROR "The python package ${PYCHECK_PACKAGE} could not be found on the host system! (for interpreter ${PYCHECK_INTERPRETER})")
    endif()
  endif()
endfunction()
