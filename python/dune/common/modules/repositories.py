""" A list of official repositories URLs """

_all_repos = {
               'dune-alugrid': 'https://gitlab.dune-project.org/extensions/dune-alugrid.git',
               'dune-common': 'https://gitlab.dune-project.org/core/dune-common.git',
               'dune-geometry': 'https://gitlab.dune-project.org/core/dune-geometry.git',
               'dune-grid': 'https://gitlab.dune-project.org/core/dune-grid.git',
               'dune-functions': 'https://gitlab.dune-project.org/staging/dune-functions.git',
               'dune-istl': 'https://gitlab.dune-project.org/core/dune-istl.git',
               'dune-localfunctions': 'https://gitlab.dune-project.org/core/dune-localfunctions.git',
               'dune-pdelab': 'https://gitlab.dune-project.org/pdelab/dune-pdelab.git',
               'dune-pdelab-howto': 'https://gitlab.dune-project.org/pdelab/dune-pdelab-howto.git',
               'dune-pdelab-systemtesting': 'https://gitlab.dune-project.org/quality/dune-pdelab-systemtesting.git',
               'dune-pdelab-tutorials': 'https://gitlab.dune-project.org/pdelab/dune-pdelab-tutorials.git',
               'dune-python': 'https://gitlab.dune-project.org/quality/dune-python.git',
               'dune-testtools': 'https://gitlab.dune-project.org/quality/dune-testtools',
               'dune-typetree': 'https://gitlab.dune-project.org/pdelab/dune-typetree.git',
            }

def get_dune_repo_url(module):
    return _all_repos.get(module, None)