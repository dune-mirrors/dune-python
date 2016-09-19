# An error checking wrapper around the cmake command execute_process
#
# .. cmake_command:: dune_execute_process
#
#    .. cmake_param:: ERROR_MESSAGE
#       :single:
#
#       Error message to show if command exited with non-zero exit code.
#
#    A thin wrapper around the cmake command :code:`execute_process`, that
#    exits on non-zero exit codes. All arguments are forwarded to the actual
#    command.
#

function(dune_execute_process)
  include(CMakeParseArguments)
  cmake_parse_arguments(EXECUTE "" "ERROR_MESSAGE" "" ${ARGN})

  execute_process(${EXECUTE_UNPARSED_ARGUMENTS}
                  RESULT_VARIABLE retcode)

  if(NOT "${retcode}" STREQUAL "0")
    message(FATAL_ERROR ${EXECUTE_ERROR_MESSAGE})
  endif()
endfunction()