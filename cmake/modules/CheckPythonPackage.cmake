# Find a given python package on the host system. Note, that you should
# only use this macro in the context of dune-python if you really need the
# package to be present on the host. Any dependencies of your python packages
# will instead be installed into the dune-python virtualenv. dune-python
# uses this module to check for the existence of python-virtualenv.
#
# check_python_package(PACKAGE package
#                      [REQUIRED])
#
# Checks for the existence of the given package on the host system. The variable
# DUNE_PYTHON_<package>_FOUND will be set correctly afterwards. If the REQUIRED
# option is set, the function will error out.
#

function(check_python_package)
  # Parse Arguments
  set(OPTION REQUIRED)
  set(SINGLE PACKAGE)
  set(MULTI)
  include(CMakeParseArguments)
  cmake_parse_arguments(PYCHECK "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(PYCHECK_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in check_python_package: This often indicates typos!")
  endif()

  execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "import ${PYCHECK_PACKAGE}" RESULT_VARIABLE PYCHECK_RETURN)
  if(PYCHECK_RETURN STREQUAL "0")
    set(DUNE_PYTHON_${PYCHECK_PACKAGE}_FOUND TRUE PARENT_SCOPE)
  else()
    set(DUNE_PYTHON_${PYCHECK_PACKAGE}_FOUND FALSE PARENT_SCOPE)
    if(PYCHECK_REQUIRED)
      message(FATAL_ERROR "The python package ${PYCHECK_PACKAGE} could not be found on the host system!")
    endif()
  endif()
endfunction()
