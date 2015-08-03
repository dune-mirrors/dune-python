# Find Sphinx - the python documentation tool
#
# You may set the following variables to modify the
# behaviour of this module:
# SPHINX_ROOT                    - the path to look for sphinx with the highest priority
#
# The following variables are set by this module:
# SPHINX_FOUND                   - whether Sphinx was found
# SPHINX_EXECUTABLE              - the path to the sphinx-build executable
#
# TODO export version.

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
