include(CheckPythonPackage)
check_python_package(PACKAGE pip REQUIRED)

string(REPLACE " " ";" CMDLINE ${CMDLINE})

include(DuneExecuteProcess)
dune_execute_process(COMMAND ${CMDLINE}
                     ERROR_MESSAGE "Cannot install python package!")
