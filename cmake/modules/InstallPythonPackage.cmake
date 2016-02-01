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
#    .. cmake_param:: NO_PIP
#       :option:
#
#       Instead of :code:`pip -e`, `python setup.py develop` will be used as
#       the installation command.
#
#    .. cmake_param:: NO_EDIT
#       :option:
#
#       Will drop :code:`pip`s :code:`-e` option (or switch :code:`develop` to :code:`install`).
#       Only use this option if your package is incompatible with :code:`-e`.
#
#    .. cmake_param:: ADDITIONAL_PIP_PARAMS
#       :multi:
#
#       Parameters to add to any :code:`pip install` call (appended).
#
#    Installs the python package located at path into the virtualenv used by dune-python
#    The package at the given location is expected to be a pip installable package.
#    Also marks the given python package for global installation during :code:`make install`.
#    By default, the python package will then be installed into the system-wide site-packages
#    location. If you do not want to install it there, or you do not have permission to,
#    you may optionally set :ref:`DUNE_PYTHON_INSTALL_USER` to a username. The
#    packages will then be installed in the home directory of that user.
#    This is done through pips :code:`--user` option. Installation in arbitrary locations is not
#    supported to minimize :code:`PYTHONPATH` issues.
#
# .. cmake_variable:: DUNE_PYTHON_INSTALL_USER
#
#    dune-python only supports two ways of globally installing python packages during
#    :code:`make install`:
#
#    * Into standard system paths (default)
#    * Into the standard python path of a users home directory (through :code:`pip --user`)
#
#    Set this variable to 1 to use the user scheme.
#

include(CheckPythonPackage)

function(dune_install_python_package)
  # Parse Arguments
  set(OPTION NO_PIP NO_EDIT)
  set(SINGLE PATH MAJOR_VERSION)
  set(MULTI ADDITIONAL_PIP_PARAMS)
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

  # Construct the installation command strings from the given options
  if(PYINST_NO_PIP)
    if(PYINST_NO_EDIT)
      set(INST_COMMAND install)
    else()
      set(INST_COMMAND develop)
    endif()
    set(VENV_INSTALL_COMMAND python setup.py ${INST_COMMAND})
  else()
    set(EDIT_OPTION)
    if(NOT PYINST_NO_EDIT)
      set(EDIT_OPTION -e)
    endif()
    set(VENV_INSTALL_COMMAND python -m pip install --ignore-installed ${PYINST_ADDITIONAL_PIP_PARAMS} ${EDIT_OPTION} .)
  endif()

  # Construct the interpreter options for global installation
  if(PYINST_NO_PIP)
    set(SYSTEM_INSTALL_OPTIONS setup.py install)
    if(DUNE_PYTHON_INSTALL_USER)
      message("Error message: Incompatible options - NO_PIP and DUNE_PYTHON_INSTALL_USER")
    endif()
  else()
    set(USER_STRING "")
    if(DUNE_PYTHON_INSTALL_USER)
      set(USER_STRING --user)
    endif()
    set(SYSTEM_INSTALL_OPTIONS -m pip install ${USER_STRING} --ignore-installed ${PYINST_ADDITIONAL_PIP_PARAMS} .)
  endif()

  # iterate over the given interpreters
  foreach(version ${PYINST_MAJOR_VERSION})
    # install the package into the virtual env
    execute_process(COMMAND ${CMAKE_BINARY_DIR}/dune-env-${version} ${VENV_INSTALL_COMMAND}
                    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${PYINST_PATH}
                    RESULT_VARIABLE retcode)
    if(NOT "${retcode}" STREQUAL "0")
      message(FATAL_ERROR "Fatal error when installing the package at ${PYINST_PATH} into the env.")
    endif()
    # define a rule on how to install the package during make install
    if(PIP${version}_FOUND)
      install(CODE "message(\"dune-python runs this install command: ${PYTHON${version}_EXECUTABLE} ${SYSTEM_INSTALL_OPTIONS}\")
                    execute_process(COMMAND ${PYTHON${version}_EXECUTABLE} ${SYSTEM_INSTALL_OPTIONS}
                                    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${PYINST_PATH}
                                    RESULT_VARIABLE retcode)
                    if(NOT \"${retcode}\" STREQUAL \"0\")
                      message(FATAL_ERROR \"Fatal error when installing the package at ${PYINST_PATH}\")
                    endif()"
             )
    else()
      install(CODE "message(FATAL_ERROR \"You need the python${version} package pip installed on the host system to install a module that contains python code\")")
    endif()
  endforeach()

  # Use a custom section to export python path to downstream modules
  set(DUNE_CUSTOM_PKG_CONFIG_SECTION "${DUNE_CUSTOM_PKG_CONFIG_SECTION}
  set(DUNE_PYTHON_SOURCE_PATHS \"${DUNE_PYTHON_SOURCE_PATHS}:${CMAKE_CURRENT_SOURCE_DIR}/${PYINST_PATH}\")
  " PARENT_SCOPE)

  # and add python path for this module
  set(DUNE_PYTHON_SOURCE_PATHS "${DUNE_PYTHON_SOURCE_PATHS}:${CMAKE_CURRENT_SOURCE_DIR}/${PYINST_PATH}" PARENT_SCOPE)

endfunction()
