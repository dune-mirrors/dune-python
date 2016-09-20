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
  This allows the use of python code at configure time and at
  build time.
* Provides rules for a target :code:`make pyinstall`, that installs
  all python packages and scripts from the current module into the
  environment of the python interpreter that was found by CMake.
* The same happens during :code:`make install` in addition to any
  other install rules your project specifies. 
* Python testing commands are wrapped into a target :code:`make pytest`.
* A python package :code:`dune.common`, which is supposed to be the
  *dune-common* of dune-related python packages.

.. _requirements:

What software is required for dune-python?
==========================================

To use dune-python, you need:
* dune-common
* A python interpreter
* The python package :code:`pip` installed
* One of the python packages :code:`virtualenv` or :code:`venv` installed

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

Every module that depends on dune-python will have a script
in its build directory to access the virtualenv. It is called
:code:`dune-env`.

Note, that those scripts are bash scripts. However, the extension :code:`sh`
has been dropped to allow to write portable code. Implementations
of those scripts for other platforms can be implemented if needed.

The packages are installed in the virtualenv with :code:`pip --editable`,
which is the equivalent of :code:`python setup.py develop`. That means
you can work on the python code in your module without upgrading
the virtualenv manually. Note, that once you are starting to mix installed
and non-installed Dune modules defining python packages, the :code:`--editable`
flag will be dropped. This is caused by this severe issue: https://github.com/pypa/pip/issues/3

.. _2vs3:

The system interpreter (aka Python2 vs. Python3)
================================================

As of September 2016, dune-python tackles the 2 vs. 3 issue in the following
way: CMake knows exactly one system python interpreter, which is the one found
by the builtin find module :code:`FindPythonInterp.cmake`.

If you want to force a major version, you have two ways:
* As an *end user* set either the CMake variable :ref:`DUNE_FORCE_PYTHON2` or
  :ref:`DUNE_FORCE_PYTHON3` to :code:`TRUE`.
* As the developer of a Dune module, use the function :ref:`dune_force_python_version`
  from within your module.

Note, that you can also activate a virtualenv before building your stack and
CMake will pick up the interpreter of that env and use it as the system interpreter.
In this case, the :code:`make pyinstall` command comes especially handy, as it
allows you to install all dune packages into your environment.
