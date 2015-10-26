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
#    .. cmake_param:: REAL_PATH
#       :single:
#
#       The variable name given to this parameter will be set to the directory
#       where the requested virtualenv is located. If used together with
#       :code:`ONLY_ONCE`, this could point into a different modules' build directory.
#
#    .. cmake_param:: ONLY_ONCE
#       :option:
#
#       If set, cmake will look through all build directories in the set of
#       modules this module depends on and only create a virtualenv, if no
#       virtualenv has been created yet. This only checks for virtualenvs in the
#       toplevel build directories of all those modules.
#
#    .. cmake_param:: INTERPRETER
#       :single:
#
#       The python interpreter to be used within the virtualenv. Defaults to
#       :code:`PYTHON2_EXECUTABLE` defined by :ref:`FindPython2Interp`.
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
# .. cmake_variable:: ENABLE_UBUNTU_WORKAROUND
#
#    Ubuntu 14.04 has a serious python3 virtualenv related bug. Check
#    https://bugs.launchpad.net/debian/+source/python3.4/+bug/1290847
#    for any details. On Ubuntu 14.04, a workaround is implemented. If you
#    run into similar problems on other debian-like systems, try setting
#    this variable to see whether you are running into the same type of
#    problems. Please report back to dominic.kempf@iwr.uni-heidelberg.de
#    in that case!

include(CheckPythonPackage)

function(create_virtualenv)
  # Parse Arguments
  set(OPTION ONLY_ONCE)
  set(SINGLE PATH NAME REAL_PATH INTERPRETER)
  set(MULTI)
  include(CMakeParseArguments)
  cmake_parse_arguments(CREATE_ENV "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(CREATE_ENV_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in create_virtualenv: This often indicates typos!")
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
                         INTERPRETER ${CREATE_ENV_INTERPRETER}
                         RESULT VIRTUALENV_FOUND)
    if(VIRTUALENV_FOUND)
      set(VIRTUALENV_PACKAGE_NAME virtualenv)
    endif()
    check_python_package(PACKAGE venv
                         INTERPRETER ${CREATE_ENV_INTERPRETER}
                         RESULT VENV_FOUND)
    if(VENV_FOUND)
      set(VIRTUALENV_PACKAGE_NAME venv)
    endif()

    # error out if none of the packages could be found.
    if(NOT VIRTUALENV_PACKAGE_NAME)
      message(FATAL_ERROR "You need either the package virtualenv or venv installed on the host system")
    endif()

    # Work around ubuntu bug https://bugs.launchpad.net/debian/+source/python3.4/+bug/1290847
    # Idea of the workaround: Install without pip and then easy_install pip into it.
    # As soon as the upstream bug is fixed, this entire if block should be deleted in favor
    # of the else block.
    if((UBUNTU_VERSION STREQUAL "14.04" OR ENABLE_UBUNTU_WORKAROUND) AND "${VIRTUALENV_PACKAGE_NAME}" STREQUAL "venv")
      message("Building a virtual env in ${CMAKE_BINARY_DIR}/${CREATE_ENV_NAME}...")
      message("Falling back to terrible things to workaround Ubuntu bugs...")
      check_python_package(PACKAGE easy_install
                           INTERPRETER ${CREATE_ENV_INTERPRETER}
                           RESULT EASY_INSTALL_FOUND
                           REQUIRED)
      # First install with --without-pip
      execute_process(COMMAND ${CREATE_ENV_INTERPRETER} -m ${VIRTUALENV_PACKAGE_NAME}
                        --system-site-packages --without-pip ${CREATE_ENV_PATH}/${CREATE_ENV_NAME})
      set(VIRTUALENV_PATH ${CREATE_ENV_PATH}/${CREATE_ENV_NAME})
      # Get a shell wrapper around the created virtualenv
      if(CMAKE_PROJECT_NAME STREQUAL dune-python)
        set(DUNE_PYTHON_TEMPLATES_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)
      else()
        set(DUNE_PYTHON_TEMPLATES_PATH ${dune-python_MODULE_PATH})
      endif()
      set(DUNE_VIRTUALENV_PATH ${VIRTUALENV_PATH})
      configure_file(${DUNE_PYTHON_TEMPLATES_PATH}/env-wrapper.sh.in ${CMAKE_BINARY_DIR}/easy_install-env.sh)
      # Now install pip into the virtualenv through easy_install
      execute_process(COMMAND ${CMAKE_BINARY_DIR}/easy_install-env.sh python -m easy_install pip)
      file(REMOVE ${CMAKE_BINARY_DIR}/easy_install-env.sh)
    else()
      # build the actual thing
      message("Building a virtual env in ${CMAKE_BINARY_DIR}/${CREATE_ENV_NAME}...")
      execute_process(COMMAND ${CREATE_ENV_INTERPRETER} -m ${VIRTUALENV_PACKAGE_NAME} --system-site-packages ${CREATE_ENV_PATH}/${CREATE_ENV_NAME})
      set(VIRTUALENV_PATH ${CREATE_ENV_PATH}/${CREATE_ENV_NAME})
    endif()
  endif()

  # Set the path to the virtualenv in the outer scope
  set(${CREATE_ENV_REAL_PATH} ${VIRTUALENV_PATH} PARENT_SCOPE)
endfunction()
