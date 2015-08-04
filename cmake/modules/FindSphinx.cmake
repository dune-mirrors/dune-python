# Find Sphinx - the python documentation tool
#
# You may set the following variables to modify the
# behaviour of this module:
#
# :ref:`SPHINX_ROOT`
#    the path to look for sphinx with the highest priority
#
# The following variables are set by this module:
#
# :code:`SPHINX_FOUND`
#    whether Sphinx was found
#
# :code:`SPHINX_EXECUTABLE`
#    the path to the sphinx-build executable
#
# TODO export version.
#
# .. cmake_variable:: SPHINX_ROOT
#
#   You may set this variable to have :ref:`FindSphinx` look
#   for the :ref:`sphinx-build` executable in the given path
#   before inspecting system paths.
#

find_program(SPHINX_EXECUTABLE
             NAMES sphinx-build
             PATHS ${SPHINX_ROOT}
             NO_DEFAULT_PATH)

find_program(SPHINX_EXECUTABLE
             NAMES sphinx-build)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  "Sphinx"
  DEFAULT_MSG
  SPHINX_EXECUTABLE
)
