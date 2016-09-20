""" The data structure for a dune.module file """


class DuneModuleFile(object):
    def __init__(self, module=None, version=None, maintainer=None, whitespace_hook=False, depends=[], suggests=[]):
        assert(module)
        self.module = module
        self.version = version
        self.maintainer = maintainer
        self.whitespace_hook = whitespace_hook
        self.depends = depends
        self.suggests = suggests

    def __str__(self):
        return "Dune Module file for module {}".format(self.module)
