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
#    Set this variable to a username to use the latter.
#

include(CheckPythonPackage)

function(dune_install_python_package)
  # Parse Arguments
  set(OPTION NO_PIP NO_EDIT)
  set(SINGLE PATH)
  set(MULTI ADDITIONAL_PIP_PARAMS)
  include(CMakeParseArguments)
  cmake_parse_arguments(PYINST "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(PYINST_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in dune_install_python_package: This often indicates typos!")
  endif()

  #
  # Install the given python package into dune-python's virtualenv
  #

  # Construct the installation command strings from the given options
  if(PYINST_NO_PIP)
    if(PYINST_NO_EDIT)
      set(INST_COMMAND install)
    else()
      set(INST_COMMAND develop)
    endif()
    set(VENV_INSTALL_COMMAND setup.py ${INST_COMMAND})
  else()
    set(EDIT_OPTION)
    if(NOT PYINST_NO_EDIT)
      set(EDIT_OPTION -e)
    endif()
    set(VENV_INSTALL_COMMAND -m pip install ${PYINST_ADDITIONAL_PIP_PARAMS} ${EDIT_OPTION} .)
  endif()

  # install the package into the virtual env
  dune_execute_process(COMMAND ${DUNE_PYTHON_VIRTUALENV_INTERPRETER} ${VENV_INSTALL_COMMAND}
                       WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${PYINST_PATH}
                       ERROR_MESSAGE "Fatal error when installing the package at ${PYINST_PATH} into the env."
                       )

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
    set(SYSTEM_INSTALL_OPTIONS -m pip install ${USER_STRING} ${PYINST_ADDITIONAL_PIP_PARAMS} .)
  endif()

  #
  # Now define rules for `make install`.
  #

  check_python_package(PACKAGE pip)

  # define a rule on how to install the package during make install
  if(DUNE_PYTHON_pip_FOUND)
    install(CODE "dune_execute_process(COMMAND ${PYTHON_EXECUTABLE} ${SYSTEM_INSTALL_OPTIONS}
                                       WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${PYINST_PATH}
                                       ERROR_MESSAGE \"Fatal error when installing the script ${PYINST_SCRIPT}\")"
            )
  else()
    install(CODE "message(FATAL_ERROR \"You need the python${version} package pip installed on the host system to install a module that contains python code\")")
  endif()

  #
  # Set some paths needed for Sphinx documentation.
  #

  # Use a custom section to export python path to downstream modules
  set(DUNE_CUSTOM_PKG_CONFIG_SECTION "${DUNE_CUSTOM_PKG_CONFIG_SECTION}
  set(DUNE_PYTHON_SOURCE_PATHS \"${DUNE_PYTHON_SOURCE_PATHS}:${CMAKE_CURRENT_SOURCE_DIR}/${PYINST_PATH}\")
  " PARENT_SCOPE)

  # and add python path for this module
  set(DUNE_PYTHON_SOURCE_PATHS "${DUNE_PYTHON_SOURCE_PATHS}:${CMAKE_CURRENT_SOURCE_DIR}/${PYINST_PATH}" PARENT_SCOPE)

endfunction()
