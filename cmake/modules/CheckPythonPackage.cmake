# Find a given python package on the host system. Note, that you should
# only use this macro in the context of dune-python if you really need the
# package to be present on the host. Any dependencies of your python packages
# will instead be installed into the dune-python virtualenv. dune-python
# uses this module to check for the existence of python-virtualenv.
#
# check_python_package(PACKAGE package
#                     [MAJOR_VERSION version]
#                     [REQUIRED])
#
# Checks for the existence of the given package on the host system. The variable
# DUNE_PYTHON<interpmajor>_<package>_FOUND will be set correctly afterwards. 
# interpmajor is 2 or 3, given the version number of the python interpreter.
# By default, the python2 and python3 interpreters found by the cmake buildsystem
# are checked. If you only want to check for python2 or python3 packages, pass
# either 2 or 3 to the MAJOR_VERSION parameter.
#
# If the REQUIRED option is set, the function will error out if the package is not
# found. If you are looking for a python2 only package with the REQUIRED option,
# remember to set MAJOR_VERSION to avoid a false positive.
#

function(check_python_package)
  # Parse Arguments
  set(OPTION REQUIRED)
  set(SINGLE PACKAGE MAJOR_VERSION)
  set(MULTI)
  include(CMakeParseArguments)
  cmake_parse_arguments(PYCHECK "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(PYCHECK_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in check_python_package: This often indicates typos!")
  endif()

  # set a list of interpreters to use
  if(NOT PYCHECK_MAJOR_VERSION)
    set(PYCHECK_MAJOR_VERSION 2 3)
  endif()

  # provide a shortcut to allow easily constructing interpreter variables
  set(PYTHON2_EXECUTABLE ${PYTHON_EXECUTABLE})
  set(PYTHON2INTERP_FOUND ${PYTHONINTERP_FOUND})

  # Iterate over the list of interpreters and look for the packages.
  foreach(version ${PYCHECK_MAJOR_VERSION})
    set(DUNE_PYTHON${version}_${PYCHECK_PACKAGE}_FOUND FALSE PARENT_SCOPE)
    if(PYTHON${version}INTERP_FOUND)
      execute_process(COMMAND ${PYTHON${version}_EXECUTABLE} -c "import ${PYCHECK_PACKAGE}" 
                      RESULT_VARIABLE PYCHECK_RETURN
                      ERROR_QUIET)
      if(PYCHECK_RETURN STREQUAL "0")
        set(DUNE_PYTHON${version}_${PYCHECK_PACKAGE}_FOUND TRUE PARENT_SCOPE)
      else()
        if(PYCHECK_REQUIRED)
          message(FATAL_ERROR "The python package ${PYCHECK_PACKAGE} could not be found on the host system! (for python${version})")
        endif()
      endif()
    endif()
  endforeach()
endfunction()
