install(FILES CheckPythonPackage.cmake
              DuneInstallPythonPackage.cmake
              DunePythonMacros.cmake
              PythonVersion.cmake
        DESTINATION ${DUNE_INSTALL_MODULEDIR})

install(FILES env-wrapper.sh.in
        DESTINATION ${DUNE_INSTALL_MODULEDIR})
        PERMISSIONS WORLD_EXECUTE)
