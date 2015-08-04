# Module to generate CMake API documentation with Sphinx
#
# There are some assumptions on how the documentation in
# the CMake modules is written:
#
# * There are blocks that are written in restructured text.
#   The first two characters of each line (:code:`# `) are ignored
#   Any resulting content of lines most form valid rst.
# * One such block is at the beginning of every module and
#   describes the general handling of the module
#
# .. cmake_function:: dune_cmake_sphinx_doc
#
#    .. cmake_param:: PATHS
#       :multi:
#
#       The set of paths to look for CMake modules. Defaults
#       to the cmake/modules subdirectory of the current module.
#       Note, that all modules must be rst-documented following
#       the criteria defined in :ref:`DuneSphinxCMakeDoc` in order
#       to successfully generate documentation.
#
#    .. cmake_param:: BUILDTYPE
#       :multi:
#
#       Set the type of build that is requested. By default, "html" is chosen.
#       The list of available build types:
#
#       * `html`
#
#    .. cmake_param:: EXCLUDE
#       :multi:
#
#       Exclude the given macros from the documentation.
#
#    .. cmake_param:: NO_DEFAULT_PATHS
#       :option:
#
#       If set, the cmake/modules subdirectory will not be searched
#       for CMake macros to generate documentation.
#
#    Generate a documentation for the CMake API. A set of cmake
#    modules defined by the parameters and all functions and macros
#    there in are automatically generated. The top level directory
#    of the documentation is the current build directory (aka the
#    directory that this function is called from)
#

dune_install_python_script(SCRIPT extract_cmake_data.py)

function(dune_cmake_sphinx_doc)
  # Only proceed if Sphinx was found on the system
  if(NOT SPHINX_FOUND)
    message("-- Skipping building CMake API documentation (install sphinx to do so)")
    return()
  endif()

  # Parse Arguments
  set(OPTION NO_DEFAULT_PATHS)
  set(SINGLE)
  set(MULTI PATHS EXCLUDE)
  include(CMakeParseArguments)
  cmake_parse_arguments(SPHINX_CMAKE "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(PYINST_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in dune_cmake_sphinx_doc: This often indicates typos!")
  endif()

  # Apply defaults
  if(NOT SPHINX_CMAKE_BUILDTYPE)
    set(SPHINX_CMAKE_BUILDTYPE html)
  endif()

  # Add default paths to the path variable
  if(NOT SPHINX_CMAKE_NO_DEFAULT_PATHS)
    set(SPHINX_CMAKE_PATHS ${SPHINX_CMAKE_PATHS} ${CMAKE_SOURCE_DIR}/cmake/modules)
  endif()

  # Determine the location of the config file template.
  if(CMAKE_PROJECT_NAME STREQUAL dune-python)
    set(DUNE_SPHINX_PATH ${CMAKE_SOURCE_DIR}/doc/sphinx)
  else()
    # TODO: How do we find the correct thing here?
  endif()

  # Generate the list of modules by looking through the given paths
  # for files matching *.cmake
  set(SPHINX_DOC_MODULE_LIST)
  foreach(path ${SPHINX_CMAKE_PATHS})
    file(GLOB modules "${path}/*.cmake")
    set(SPHINX_DOC_MODULE_LIST ${SPHINX_DOC_MODULE_LIST} ${modules})
  endforeach()

  # Initialize a variable that collect all dependencies of the documentation
  set(DOC_DEPENDENCIES)

  # Generate the rst files for all cmake modules
  foreach(module ${SPHINX_DOC_MODULE_LIST})
    get_filename_component(modname ${module} NAME)
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/modules/${modname}
                       COMMAND ${CMAKE_BINARY_DIR}/dune-env extract_cmake_data.py
                         --module=${module}
                         --builddir=${CMAKE_CURRENT_BINARY_DIR}
                       DEPENDS ${module})
    set(DOC_DEPENDENCIES ${DOC_DEPENDENCIES} ${CMAKE_CURRENT_BINARY_DIR}/modules/${modname})
  endforeach()

  # copy the rst files that are fixed to the build directory during configure
  #configure_file(${CMAKE_CURRENT_SOURCE_DIR}/index.rst.in ${CMAKE_CURRENT_BINARY_DIR}/index.rst)
  file(GLOB rstfiles "${CMAKE_CURRENT_SOURCE_DIR}/*.rst")
  foreach(rst ${rstfiles})
    get_filename_component(rstname ${rst} NAME)
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${rstname}
                       COMMAND ${CMAKE_COMMAND} -E copy ${rst} ${CMAKE_CURRENT_BINARY_DIR})
    set(DOC_DEPENDENCIES ${DOC_DEPENDENCIES} ${CMAKE_CURRENT_BINARY_DIR}/${rstname})
  endforeach()

  # Configure the conf.py from the template
  # TODO: For now, this is copyonly
  configure_file(${DUNE_SPHINX_PATH}/conf.py ${CMAKE_CURRENT_BINARY_DIR}/conf.py COPYONLY)

  # We

  # Call Sphinx once for each requested build type
  foreach(type ${SPHINX_CMAKE_BUILDTYPE})
    # Call the sphinx executable
    add_custom_target(sphinx_${type}
                      COMMAND ${SPHINX_EXECUTABLE}
                                -b ${type}
                                -w ${CMAKE_BINARY_DIR}/SphinxError.log
                                -c ${CMAKE_CURRENT_BINARY_DIR}
                                ${CMAKE_CURRENT_BINARY_DIR}
                                ${CMAKE_CURRENT_BINARY_DIR}/${type}
                      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                      DEPENDS ${DOC_DEPENDENCIES}
                     )
    add_dependencies(doc sphinx_${type})
  endforeach()
endfunction()