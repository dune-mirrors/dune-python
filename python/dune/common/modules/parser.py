from __future__ import absolute_import
from __future__ import print_function

from pyparsing import *
from dune.common.modules.file import DuneModuleFile

class DuneModuleFileParser(object):
    _debug = False

    singleKeys = ["Module", "Version", "Maintainer", "Whitespace-Hook"]
    multiKeys = ["Depends", "Suggests"]

    def __init__(self):
        self._parser = self.construct_bnf()
        if DuneModuleFileParser._debug:
            print("The BNF: {}".format(self._parser))

    def _bnf_from_key(self, key):
        bnf = Literal('{}:'.format(key)).suppress() + Word(printables).setParseAction(self.setVariable(key.replace('-','_').lower()))
        if DuneModuleFileParser._debug:
            print("Constructing a BNF for {}: {}".format(key, bnf))
        return bnf

    def _bnf_versioned_list(self, key):
        requirement = Word(printables, excludeChars="()").setParseAction(self.appendVariable(key.lower()))
        version = Optional(Literal("(").suppress() + Word(printables + " ", excludeChars=")") + Literal(")").suppress())
        # TODO do not suppress the version here, but use it instead
        entry = requirement + version.suppress()
        requlist = OneOrMore(entry)
        bnf = Literal('{}:'.format(key)).suppress() + requlist
        return bnf

    def construct_bnf(self):
        simplekeys = [self._bnf_from_key(k) for k in DuneModuleFileParser.singleKeys]
        multikeys = [self._bnf_versioned_list(k) for k in DuneModuleFileParser.multiKeys]
        comment = [(Literal('#') + Word(printables + " ")).suppress(), Empty()]
        bnflist = simplekeys + multikeys + comment

        line = bnflist[0]
        for b in bnflist[1:]:
            line = line | b
        line = line + LineEnd()

        return line

    def appendVariable(self, var):
        def _parseAction(origString, loc, tokens):
            if DuneModuleFileParser._debug:
                print("Appending to self.result[{}] to {}".format(var, tokens[0]))
            if var not in self.result:
                self.result[var] = []
            self.result[var].append(tokens[0])
        return _parseAction

    def setVariable(self, var):
        def _parseAction(origString, loc, tokens):
            if DuneModuleFileParser._debug:
                print("Setting self.result[{}] to {}".format(var, tokens[0]))
            self.result[var] = tokens[0]
        return _parseAction

    def apply(self, filename):
        if DuneModuleFileParser._debug:
            print("Parsing file: {}".format(filename))
        f = open(filename, 'r')
        self.result = {}
        for line in f:
            if DuneModuleFileParser._debug:
                print("Parsing line: {}".format(line[:-1]))
            self._parser.parseString(line)

        return DuneModuleFile(**self.result)

def parse_dune_module_file(filename):
    return DuneModuleFileParser().apply(filename)
