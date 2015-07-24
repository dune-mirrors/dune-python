# include all macros that dune-python offers. They can be documented better if placed
# in cmake modules grouped together by functionality
include(CheckPythonPackage)
include(InstallPythonPackage)
include(PythonVersion)

# The code we do want to execute whenever a module that requires or suggests dune-pyhton is configured
find_package(PythonInterp REQUIRED)
check_python_package(PACKAGE virtualenv REQUIRED)
