install(FILES CheckPythonPackage.cmake
              DuneInstallPythonPackage.cmake
              DunePythonMacros.cmake
              env-wrapper.sh.in
              PythonVersion.cmake
        DESTINATION ${DUNE_INSTALL_MODULEDIR})
