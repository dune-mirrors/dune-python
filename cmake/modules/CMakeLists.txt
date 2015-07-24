install(FILES CheckPythonPackage.cmake
              DunePythonMacros.cmake
              InstallPythonPackage.cmake
              env-wrapper.sh.in
              PythonVersion.cmake
        DESTINATION ${DUNE_INSTALL_MODULEDIR})
