===========
dune-python
===========

.. _whatabout:

What is dune-python about?
==========================

dune-python provides infrastructure for dune modules that do
ship python packages.

In particular, dune-python offers:

* A virtualenv that lives in a cmake build directory, where
  all python packages shipped by dune modules are installed.
* Integration of the python package installation process into
  the cmake build system.
* CMake modules helpful with python issues, such as searching
  for installed packages etc.
* A python package :code:`dune.common`, which is supposed to be the
  *dune-common* of dune-related python packages.

.. _howto:

How to use dune-python
======================

When developing a dune module, you should do the following:

* Have your dune module depend on dune-python
* Put all your python code into the subdirectory :code:`python`
  in your module. While this is not technically necessary,
  it simplifies grasping how modules are structured.
* Write your python code as :code:`pip`-installable packages.
  Comprehensive information on how to do that can be found
  here: https://packaging.python.org/en/latest/distributing.html.
* If your module is named :code:`dune-foo`, name the python package
  :code:`dune.foo`, unless you have good reason to name it differently.
* Tell the cmake build system, to install the python package:
  with the module :ref:`dune_install_python_package`.
  This will install the package into a virtualenv (see below)
  at configure time and will globally install it during
  :code:`make install`.
* As an alternative to writing a :code:`pip`-installable package,
  dune-python can handle executable python scripts and their
  upstream dependencies manually. Use the macro
  :ref:`dune_install_python_script` in that case.

.. note::

   Naming a package :code:`dune.foo` will require the package dune
   to be a namespace package, otherwise you will run into this
   pip issue: https://github.com/pypa/pip/issues/3.
   To make it a namespace package, you need to add
   ::

      namespace_packages = ['dune']

   to the arguments of the :code:`setup` function and add an :code:`__init__.py`
   module containing the following line to the :code:`dune` subfolder:
   ::

      __import__('pkg_resources').declare_namespace(__name__)

.. _virtualenv:

The dune-python virtualenv concept
==================================

The idea behind the virtualenv provided by dune-python is, to
automatically set up an environment for running python code at
configure time. A virtualenv is the python way of achieving this goal.

To minimize needed disk space and to enable complex interplay between
python packages provided by different module, dune-python will create
but one virtualenv per python version, no matter how many Dune modules
provide python packages. That virtualenv lives in the build directory
of the first non-installed module of the build stack.

Every module that depends on dune-python will have a set of scripts
in its build directory to access the virtualenv. Currently those are:

* :code:`dune-env-{2,3}` runs the command given by its arguments within the
  python{2,3} virtualenv and returns the return value.
* :code:`dune-env` is the same as above with python3 if available and python2
  otherwise.
* :code:`python{2,3}` gives you a python2 or python3 interpreter running in
  the virtualenv
* :code:`python` is the same as above with python3 if available and python2
  otherwise.

Note, that those scripts are bash scripts. However, the extension :code:`sh`
has been dropped to allow to write portable code. Implementations
of those scripts for other platforms can be implemented if needed.

Note, that the virtualenv has access to the system site packages
(otherwise you couldn't combine installed dune modules with local
ones). Still, you do need internet connection to install python
packages inside the virtualenv, that ar enot present on the host system.

The packages are installed in the virtualenv with :code:`pip --editable`,
which is the equivalent of :code:`python setup.py develop`. That means
you can work on the python code in your module without upgrading
the virtualenv manually.

Portability is not yet implemented (but can be achieved within CMake),
so dune-python is currently limited to UNIX systems.


.. _2vs3:

Python2 vs. Python3
===================

The transition from python2 to python3 is a major issue when treating
build system issues. dune-python aims at full support for both python2
and python3.

There are two virtualenvs: One for python2, one for python3. All scripts
have the version number in their naming.

If your python package is written to support both python2 and python3
you should not be forced to take specific measures. If you do not support
one of them, read the documentation of the cmake modules in dune-python/cmake/modules
carefully. All macros offer some parameters to customize the build process
for different python versions.