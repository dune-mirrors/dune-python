# Prerequisites

The following software is required to work with dune-python:

* [dune-common](www.dune-project.org)
* A python interpreter
* [pip](https://pypi.python.org/pypi/pip)

To work with python2:

* [virtualenv](https://pypi.python.org/pypi/virtualenv)

To build the documentation:

* [sphinx](https://pypi.python.org/pypi/Sphinx/)

# What is dune-python?

dune-python provides infrastructure for dune modules that do
ship python packages.

In particular, dune-python offers:

* A virtualenv that lives in a cmake build directory, where
  all python packages shipped by dune modules are installed.
* Integration of the python package installation process into
  the cmake build system.
* CMake modules helpful with python issues, such as searching
  for installed packages etc.
* A python package `dune.common`, which is supposed to be the
  "dune-common" of dune-related python packages.

# Documentation

Type `make doc` in the build directory of dune-python to generate
the html documentation of dune-python. It is placed in the subfolder
`doc/sphinx/html`.

# Getting help

If you have any questions about dune-python, please contact

Dominic Kempf [dominic.kempf@iwr.uni-heidelberg.de](mailto:dominic.kempf@iwr.uni-heidelberg.de)

# Acknowledgments

The work by Timo Koch and Dominic Kempf is supported by the
ministry of science, research and arts of the federal state of
Baden-Württemberg (Ministerium für Wissenschaft, Forschung
und Kunst Baden-Württemberg).
