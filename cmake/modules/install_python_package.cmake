include(CheckPythonPackage)
check_python_package(PACKAGE pip)

if(NOT DUNE_PYTHON_pip_FOUND)
  message(FATAL_ERROR "You need pip installed on the host system to globally install python packages")
endif()

string(REPLACE " " ";" CMDLINE ${CMDLINE})

include(DuneExecuteProcess)
dune_execute_process(COMMAND ${CMDLINE}
                     ERROR_MESSAGE "Cannot install python package!")
