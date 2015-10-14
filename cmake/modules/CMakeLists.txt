install(FILES CheckPythonPackage.cmake
              CheckUbuntu.cmake
              CreateVirtualEnv.cmake
              DunePythonMacros.cmake
              DunePythonTesting.cmake
              DuneSphinxCMakeDoc.cmake
              FindPython2Interp.cmake
              FindPython3Interp.cmake
              FindSphinx.cmake
              InstallPythonPackage.cmake
              InstallPythonScript.cmake
              PythonVersion.cmake
              sphinx_cmake_dune.py
              VirtualEnvWrapper.cmake
        DESTINATION ${DUNE_INSTALL_MODULEDIR})

# The wrapper templates need to be executable, even
# when installed. That way we do not need to set the
# permissions of the configured file manually.
install(FILES env-wrapper.sh.in
        DESTINATION ${DUNE_INSTALL_MODULEDIR}
        PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
                    GROUP_READ GROUP_EXECUTE
                    WORLD_READ WORLD_EXECUTE)
