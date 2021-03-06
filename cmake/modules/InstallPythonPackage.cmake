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
#    This macro installs the python package located at path. It
#
#    * installs it inside the dune-python virtualenv at configure time
#    * installs it into the environment of the found python interpreter during
#      :code:`make pyinstall` and during :code:`make install`.
#    * installs a wheel into the dune-python wheelhouse during :code:`make install`.
#      This is necessary for mixing installed and non-installed Dune modules.
#
#    The package at the given location is expected to be a pip installable package.
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
  set(WHEEL_ARG "")
  if(IS_DIRECTORY ${DUNE_PYTHON_WHEELHOUSE})
    set(WHEEL_ARG "--find-links=${DUNE_PYTHON_WHEELHOUSE}")
    #
    # The following line is a bummer!
    # We cannot have editable packages once we start using global installations!
    # This is related to the nightmare that is https://github.com/pypa/pip/issues/3
    #
    set(PYINST_NO_EDIT TRUE)
  endif()
  if(PYINST_NO_PIP)
    if(PYINST_NO_EDIT)
      set(INST_COMMAND install)
    else()
      set(INST_COMMAND develop)
    endif()
    set(VENV_INSTALL_COMMAND setup.py ${INST_COMMAND} ${WHEEL_ARG})
  else()
    set(EDIT_OPTION)
    if(NOT PYINST_NO_EDIT)
      set(EDIT_OPTION -e)
    endif()
    set(VENV_INSTALL_COMMAND -m pip install ${PYINST_ADDITIONAL_PIP_PARAMS} ${EDIT_OPTION} ${WHEEL_ARG} .)
  endif()

  # install the package into the virtual env
  dune_execute_process(COMMAND ${DUNE_PYTHON_VIRTUALENV_INTERPRETER} ${VENV_INSTALL_COMMAND}
                       WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${PYINST_PATH}
                       ERROR_MESSAGE "Fatal error when installing the package at ${PYINST_PATH} into the env."
                       )

  # Construct the interpreter options for global installation
  if(PYINST_NO_PIP)
    set(SYSTEM_INSTALL_CMDLINE ${PYTHON_EXECUTABLE} setup.py install ${WHEEL_ARG})
    if(DUNE_PYTHON_INSTALL_USER)
      message("Error message: Incompatible options - NO_PIP and DUNE_PYTHON_INSTALL_USER")
    endif()
  else()
    set(USER_STRING "")
    if(DUNE_PYTHON_INSTALL_USER)
      set(USER_STRING --user)
    endif()
    set(SYSTEM_INSTALL_CMDLINE ${PYTHON_EXECUTABLE} -m pip install ${USER_STRING} ${PYINST_ADDITIONAL_PIP_PARAMS} ${WHEEL_ARG} ${CMAKE_CURRENT_SOURCE_DIR}/${PYINST_PATH})
  endif()

  #
  # Now define rules for `make pyinstall`.
  #

  dune_module_path(MODULE dune-python
                   RESULT DUNE_PYTHON_MODULE_DIR
                   CMAKE_MODULES)

  # Determine a target name for installing this package
  string(REPLACE "/" "_" name_suffix ${PYINST_PATH})
  set(targetname "pyinstall_${name_suffix}")

  # Add a custom target that globally installs this package if requested
  add_custom_target(${targetname}
                    COMMAND ${CMAKE_COMMAND}
                            -DCMAKE_MODULE_PATH=${DUNE_PYTHON_MODULE_DIR}
                            -DCMDLINE="${SYSTEM_INSTALL_CMDLINE}"
                            -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
                             -P ${DUNE_PYTHON_MODULE_DIR}/install_python_package.cmake
                    COMMENT "Installing the python package at ${CMAKE_CURRENT_SOURCE_DIR}/${PYINST_PATH}"
                    )

  add_dependencies(pyinstall ${targetname})

  #
  # Define rules for `make install` that install a wheel into a central wheelhouse
  #
  # NB: This is necessary, to allow mixing installed and non-installed modules
  #     with python packages. The wheelhouse will allow to install any missing
  #     python packages into the virtualenv.
  #

  # Construct the wheel installation commandline
  if(PYINST_NO_PIP)
    set(WHEEL_COMMAND setup.py bdist_wheel)
  else()
    set(WHEEL_COMMAND -m pip wheel)
  endif()

  set(WHEEL_COMMAND ${PYTHON_EXECUTABLE} ${WHEEL_COMMAND} -w ${DUNE_PYTHON_WHEELHOUSE} ${WHEEL_ARG} ${CMAKE_CURRENT_SOURCE_DIR}/${PYINST_PATH})

  install(CODE "message(\"Installing wheel for python package at ${CMAKE_CURRENT_SOURCE_DIR}/${PYINST_PATH}...\")
                dune_execute_process(COMMAND ${WHEEL_COMMAND}
                                     ERROR_MESSAGE \"Error installing wheel for python package at ${CMAKE_CURRENT_SOURCE_DIR}/${PYINST_PATH}\"
                                     )"
          )

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
