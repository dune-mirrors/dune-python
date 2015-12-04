# .. cmake_module::
#
#    Find the Sphinx APIDoc
#
#    This is a part of the Sphinx project. Instead of
#    having this separate test, the dune-common one could
#    be more comprehensive. Having this one makes it easier
#    to backport to the release though.
#
#    You may set the following variables to modify the
#    behaviour of this module:
#
#    :ref:`SPHINX_ROOT`
#       the path to look for sphinx with the highest priority
#
#    The following variables are set by this module:
#
#    :code:`SPHINX_APIDOC_FOUND`
#       whether Sphinx was found
#
#    :code:`SPHINX_APIDOC_EXECUTABLE`
#       the path to the sphinx-build executable
#

#TODO export version.

find_program(SPHINX_APIDOC_EXECUTABLE
             NAMES sphinx-apidoc
             PATHS ${SPHINX_ROOT}
             NO_DEFAULT_PATH)

find_program(SPHINX_APIDOC_EXECUTABLE
             NAMES sphinx-apidoc)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  "SphinxAPIDoc"
  DEFAULT_MSG
  SPHINX_APIDOC_EXECUTABLE
)
