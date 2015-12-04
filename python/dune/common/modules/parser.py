from __future__ import absolute_import
from __future__ import print_function

from pyparsing import *

class DuneModuleFileParser(object):
    _debug = False

    keylist = ["Module", "Version", "Maintainer", "Whitespace-Hook"]

    def __init__(self):
        self._parser = self.construct_bnf()
        if DuneModuleFileParser._debug:
            print("The BNF: {}".format(self._parser))

    def _bnf_from_key(self, key):
        bnf = Literal('{}:'.format(key)).suppress() + Word(printables).setParseAction(self.setVariable(key.replace('-','_').lower()))
        if DuneModuleFileParser._debug:
            print("Constructing a BNF for {}: {}".format(key, bnf))
        return bnf

    def construct_bnf(self):
        bnflist = [self._bnf_from_key(k) for k in DuneModuleFileParser.keylist]
        line = bnflist[0]
        for b in bnflist[1:]:
            line = line | b
        line = line + LineEnd()

        return line

    def setVariable(self, var):
        def _parseAction(origString, loc, tokens):
            if DuneModuleFileParser._debug:
                print("Setting self.{} to {}".format(var, tokens[0]))
            setattr(self, var, tokens[0])
        return _parseAction

    def apply(self, filename):
        if DuneModuleFileParser._debug:
            print("Parsing file: {}".format(filename))
        f = open(filename, 'r')
        for line in f:
            if DuneModuleFileParser._debug:
                print("Parsing line: {}".format(line[:-1]))
            self._parser.parseString(line)

        return (self.module, self.version, self.maintainer, self.whitespace_hook)

def parse_dune_module_file(filename):
    return DuneModuleFileParser().apply(filename)
