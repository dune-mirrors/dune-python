# This module provides the code that creates the Dune virtualenvs.
#
# .. cmake_function:: create_virtualenv
#
#    .. cmake_brief::
#
#       Create a new virtualenv!
#
#    .. cmake_param:: NAME
#       :single:
#       :required:
#
#       Sets the name of the directory that the virtualenv is placed in.
#       This is also used to identify virtualenvs for the :code:`ONLY_ONCE` option.
#
#    .. cmake_param:: PATH
#       :single:
#
#       The working directory where to place virtualenv directory in.
#       Defaults to the root build directory :code:`CMAKE_BINARY_DIR`.
#
#    .. cmake_param:: EXPORT_PATH
#       :single:
#
#       The variable name given to this parameter will be set to the directory
#       where the requested virtualenv is located. If used together with
#       :code:`ONLY_ONCE`, this could point into a different modules' build directory.
#       Defaults to :code:`DUNE_PYTHON_VIRTUALENV_PATH`.
#
#    .. cmake_param:: EXPORT_INTERPRETER
#       :single:
#
#       The variable name given to this parameter will be set to the location of
#       the python interpreter in dune-pythons virtualenv. Defaults to
#       :code:`DUNE_PYTHON_VIRTUALENV_INTERPRETER`
#
#    .. cmake_param:: ONLY_ONCE
#       :option:
#
#       If set, cmake will look through all build directories in the set of
#       modules this module depends on and only create a virtualenv, if no
#       virtualenv has been created yet. This only checks for virtualenvs in the
#       toplevel build directories of all those modules.
#
#    See :ref:`virtualenv` for details on what the Dune virtualenvs are used for.
#
#    .. note::
#
#       This function is used by dune-python to create the default virtualenvs,
#       that any downstream module will also use.
#       As a normal user, you should not need to use this macro directly.
#       You may still do so if you need to create custom virtualenvs at
#       configure time.
#

include(CheckPythonPackage)

function(create_virtualenv)
  # Parse Arguments
  set(OPTION ONLY_ONCE)
  set(SINGLE PATH NAME EXPORT_PATH EXPORT_INTERPRETER)
  set(MULTI)
  include(CMakeParseArguments)
  cmake_parse_arguments(CREATE_ENV "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(CREATE_ENV_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in create_virtualenv: This often indicates typos!")
  endif()

  # apply defaults
  if(NOT CREATE_ENV_PATH)
    set(CREATE_ENV_PATH ${CMAKE_BINARY_DIR})
  endif()
  if(NOT CREATE_ENV_EXPORT_PATH)
    set(CREATE_ENV_EXPORT_PATH DUNE_PYTHON_VIRTUALENV_PATH)
  endif()
  if(NOT CREATE_ENV_EXPORT_INTERPRETER)
    set(CREATE_ENV_EXPORT_INTERPRETER DUNE_PYTHON_VIRTUALENV_INTERPRETER)
  endif()

  # check whether a virtualenv that matches our need already accepts
  if(CREATE_ENV_ONLY_ONCE)
    # First iterate over the list of dependencies and look for virtualenvs
    set(VIRTUALENV_PATH)
    foreach(mod ${ALL_DEPENDENCIES})
      if(IS_DIRECTORY ${${mod}_DIR}/${CREATE_ENV_NAME})
        set(VIRTUALENV_PATH ${${mod}_DIR}/${CREATE_ENV_NAME})
      endif()
      # check in the current build directory - this might be a reconfigure
      if(IS_DIRECTORY ${CMAKE_BINARY_DIR}/${CREATE_ENV_NAME})
        set(VIRTUALENV_PATH ${CMAKE_BINARY_DIR}/${CREATE_ENV_NAME})
      endif()
    endforeach()
  endif()

  # create virtualenv only if really needed
  if(NOT CREATE_ENV_ONLY_ONCE OR NOT VIRTUALENV_PATH)
    # determine the name of the virtualenv package. Its either virtualenv or venv
    set(VIRTUALENV_PACKAGE_NAME)
    check_python_package(PACKAGE virtualenv
                         RESULT VIRTUALENV_FOUND)
    if(VIRTUALENV_FOUND)
      set(VIRTUALENV_PACKAGE_NAME virtualenv)
      set(NOPIP_OPTION --no-pip)
    endif()
    check_python_package(PACKAGE venv
                         RESULT VENV_FOUND)
    if(VENV_FOUND)
      set(VIRTUALENV_PACKAGE_NAME venv)
      set(NOPIP_OPTION --without-pip)
    endif()

    # error out if none of the packages could be found.
    if(NOT VIRTUALENV_PACKAGE_NAME)
      message(FATAL_ERROR "You need either the package virtualenv or venv installed!")
    endif()

    # Do the actual thing and build the virtualenv. As many debianish systems have some
    # some severe bugs concerning pip and virtualenvs (see here for details:
    # https://bugs.launchpad.net/debian/+source/python3.4/+bug/1290847 )
    # we install pip via the get-pip script from https://bootstrap.pypa.io/get-pip.py
    # instead of having virtualenv install it into the env.
    message("Building a virtual env in ${CMAKE_BINARY_DIR}/${CREATE_ENV_NAME}...")

    # First, we create a virtualenv without pip
    dune_execute_process(COMMAND ${PYTHON_EXECUTABLE}
                                -m ${VIRTUALENV_PACKAGE_NAME}
                                ${NOPIP_OPTION}
                                ${CREATE_ENV_PATH}/${CREATE_ENV_NAME}
                         ERROR_MESSAGE "Fatal error when setting up the env."
                         )
    set(VIRTUALENV_PATH ${CREATE_ENV_PATH}/${CREATE_ENV_NAME})

    # Now download the get-pip script
    file(DOWNLOAD https://bootstrap.pypa.io/get-pip.py ${CMAKE_CURRENT_BINARY_DIR}/get-pip.py)

    # Now install pip into the virtualenv and remove the helper
    dune_execute_process(COMMAND ${VIRTUALENV_PATH}/bin/python ${CMAKE_CURRENT_BINARY_DIR}/get-pip.py
                         ERROR_MESSAGE "Fatal error when setting up the env."
                         )
  endif()

  # Set the path to the virtualenv in the outer scope
  set(${CREATE_ENV_EXPORT_PATH} ${VIRTUALENV_PATH} PARENT_SCOPE)
  set(${CREATE_ENV_EXPORT_INTERPRETER} ${VIRTUALENV_PATH}/bin/python PARENT_SCOPE)
endfunction()
