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
  cmake_parse_arguments(EXECUTE "" "ERROR_MESSAGE;RESULT_VARIABLE;OUTPUT_VARIABLE" "" ${ARGN})

  execute_process(${EXECUTE_UNPARSED_ARGUMENTS}
                  RESULT_VARIABLE retcode
                  OUTPUT_VARIABLE log
                  ERROR_VARIABLE log)

  if(NOT "${retcode}" STREQUAL "0")
    cmake_parse_arguments(ERR "" "" "COMMAND" ${EXECUTE_UNPARSED_ARGUMENTS})
    message(FATAL_ERROR "${EXECUTE_ERROR_MESSAGE}\nRun command:${ERR_COMMAND}\nReturn code: ${retcode}\nDetailed log:\n${log}")
  endif()

  if(EXECUTE_RESULT_VARIABLE)
    set(${EXECUTE_RESULT_VARIABLE} 0 PARENT_SCOPE)
  endif()
  if(EXECUTE_OUTPUT_VARIABLE)
    set(${EXECUTE_OUTPUT_VARIABLE} ${log} PARENT_SCOPE)
  endif()
endfunction()
