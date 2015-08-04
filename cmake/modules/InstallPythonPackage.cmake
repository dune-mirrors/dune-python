# This cmake module provides macros that install python packages into the virtualenv
# that is shared by all dune modules that depend on dune-python.
#
# .. cmake_function:: dune_install_python_package
#
#    .. cmake_param:: PATH
#       :required:
#       :single:
#
#       Relative path to the given python package source code.
#
#    .. cmake_param:: MAJOR_VERSION
#       :single:
#
#       Set to "2" or "3" if your python package only works with
#       python2 or python3. This will restrict the installation process to that
#       python version.
#
#    Installs the python package located at path into the virtualenv used by dune-python
#    The package at the given location is expected to be a pip installable package.
#    Also marks the given python package for global installation during :code:`make install`.
#    By default, the python package will then be installed into the system-wide site-packages
#    location. If you do not want to install it there, or you do not have permission to,
#    you may optionally set the :code:`DUNE_PYTHON_INSTALL_USER` parameter to a username. The
#    packages will then be installed in the home directory of that user.
#    This is done through pips :code:`--user` option. Installation in arbitrary locations is not
#    supported to minimize :code:`PYTHONPATH` issues.
#

include(CheckPythonPackage)

function(dune_install_python_package)
  # Parse Arguments
  set(OPTION)
  set(SINGLE PATH MAJOR_VERSION)
  set(MULTI)
  include(CMakeParseArguments)
  cmake_parse_arguments(PYINST "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(PYINST_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in dune_install_python_package: This often indicates typos!")
  endif()

  # apply defaults
  if(NOT PYINST_MAJOR_VERSION)
    set(PYINST_MAJOR_VERSION 2 3)
  endif()

  # check for available pip packages
  check_python_package(PACKAGE pip
                       INTERPRETER ${PYTHON2_EXECUTABLE}
                       RESULT PIP2_FOUND)
  check_python_package(PACKAGE pip
                       INTERPRETER ${PYTHON3_EXECUTABLE}
                       RESULT PIP3_FOUND)

  # iterate over the given interpreters
  foreach(version ${PYINST_MAJOR_VERSION})
    # install the package into the virtual env
    execute_process(COMMAND ${CMAKE_BINARY_DIR}/dune-env-${version} pip install -e .
                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/${PYINST_PATH})

    # define a rule on how to install the package during make install
    if(PIP${version}_FOUND)
      set(USER_STRING "")
      if(DUNE_PYTHON_INSTALL_USER)
        set(USER_STRING "--user ${DUNE_PYTHON_INSTALL_USER}")
      endif()
      install(CODE "execute_process(COMMAND ${PYTHON${version}_EXECUTABLE} -m pip install ${USER_STRING} .
                                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/${PYINST_PATH})
                   ")
    else()
      install(CODE "message(FATAL_ERROR \"You need the python${version} package pip installed on the host system to install a module that contains python code\")")
    endif()
  endforeach()
endfunction()
