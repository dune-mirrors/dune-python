/* begin dune-python
   put the definitions for config.h specific to
   your project here. Everything above will be
   overwritten
*/

/* begin private */
/* Name of package */
#define PACKAGE "@DUNE_MOD_NAME@"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "@DUNE_MAINTAINER@"

/* Define to the full name of this package. */
#define PACKAGE_NAME "@DUNE_MOD_NAME@"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "@DUNE_MOD_NAME@ @DUNE_MOD_VERSION@"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "@DUNE_MOD_NAME@"

/* Define to the home page for this package. */
#define PACKAGE_URL "@DUNE_MOD_URL@"

/* Define to the version of this package. */
#define PACKAGE_VERSION "@DUNE_MOD_VERSION@"

/* end private */

/* Define to the version of dune-python */
#define DUNE_PYTHON_VERSION "@DUNE_PYTHON_VERSION@"

/* Define to the major version of dune-python */
#define DUNE_PYTHON_VERSION_MAJOR @DUNE_PYTHON_VERSION_MAJOR@

/* Define to the minor version of dune-python */
#define DUNE_PYTHON_VERSION_MINOR @DUNE_PYTHON_VERSION_MINOR@

/* Define to the revision of dune-python */
#define DUNE_PYTHON_VERSION_REVISION @DUNE_PYTHON_VERSION_REVISION@

/* Whether a python2 interpreter has been found on the system */
#define HAVE_PYTHON2_EXECUTABLE @PYTHON2INTERP_FOUND@

/* Whether a python3 interpreter has been found on the system */
#define HAVE_PYTHON3_EXECUTABLE @PYTHON3INTERP_FOUND@

/* Export the python2 interpreter found by the CMake build system */
#define PYTHON2_EXECUTABLE @PYTHON2_EXECUTABLE@

/* Export the python2 interpreter found by the CMake build system */
#define PYTHON3_EXECUTABLE @PYTHON3_EXECUTABLE@

/* end dune-python
   Everything below here will be overwritten
*/
