""" Determine the closure of requirements (or suggestions) of a Dune
module. This requires to access the repositories! """

import subprocess
import os
from dune.common.modules.file import DuneModuleFile
from dune.common.modules.repositories import get_dune_repo_url
from dune.common.modules.parser import parse_dune_module_file
from itertools import chain


def get_dune_module_file(module, hints={}, workdir=None):
    if workdir is None:
        workdir = os.path.abspath(os.getcwd())
    workdir = os.path.join(workdir, 'gdmf')
    if not os.path.exists(workdir):
        os.makedirs(workdir)

    # Determine the URL by looking first into the hints dictionary
    # and then into our registry!
    url = hints.get(module, None)
    if not url:
        url = get_dune_repo_url(module)
    if not url:
        print("Fatal error! No git url found for the module {}".format(module))
        import sys
        sys.exit(1)

    # TODO maybe check here, that there is no directory called module in the working directory

    # Now download the 'dune.module' file from the given URL
    # TODO Add error checking here!
    subprocess.call("git clone -n {} --depth 1 ".format(url).split(), cwd=workdir)
    clonepath = os.path.join(workdir, module)
    subprocess.call("git checkout HEAD dune.module".split(), cwd=clonepath)

    # Parse the module file
    modfile = parse_dune_module_file(os.path.join(clonepath, 'dune.module'))

    # Now delete the clone
    subprocess.call("rm -rf {}".format(clonepath).split())

    return modfile


def get_dune_module_closure(module, repocache={}, workdir=None):
    assert isinstance(module, DuneModuleFile)

    # Iterate over the list of explicitly stated dependencies and determine
    # their closure recursively. DuneModuleFile instances with dependencies
    # with full closure are added to the repocache to speed up things.
    depends_closure = []
    for mod in module.depends:
        if mod not in repocache:
            repocache[mod] = get_dune_module_closure(get_dune_module_file(mod, workdir=workdir), repocache=repocache, workdir=workdir)
        depends_closure.extend(repocache[mod].depends)

    # Then, update the dependencies list of the current module.
    module.depends = list(set([i for i in chain(module.depends, depends_closure)]))

    # Do the same for suggestions
    suggestions_closure = []
    for mod in module.suggests:
        if mod not in repocache:
            repocache[mod] = get_dune_module_closure(get_dune_module_file(mod, workdir=workdir), repocache=repocache, workdir=workdir)

        # Here, we also consider requirements of suggestions, which might turn into
        # suggestions of downstream modules!
        suggestions_closure.extend(repocache[mod].depends)
        suggestions_closure.extend(repocache[mod].suggests)

    # Update the list of suggestions, only list real suggestions!
    module.suggests = [l for l in list(set([i for i in chain(module.suggests, suggestions_closure)])) if l not in module.depends]

    # If this module is not yet in the cache, we add it (dune-common only ?!).
    repocache.setdefault(module.module, module)

    return module
