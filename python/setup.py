from setuptools import setup

setup(name='dune.common',
      namespace_packages=['dune'],
      version='2.4',
      description='Python package accompanying the DUNE project',
      url='http://www.dune-project.org',
      author='Dominic Kempf',
      author_email='dominic.kempf@iwr.uni-heidelberg.de',
      license='BSD',
      packages=['dune.common', 'dune.common.parametertree', 'dune.common.modules'])
