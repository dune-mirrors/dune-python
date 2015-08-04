#!/usr/bin/env python

""" This script will parse a cmake module and extract some_key
    rst documentation from it. This might not be as elegant as
    writing a Sphinx domain or using a custom extension with
    cmake related directives, but it provides a straightforward
    working way.
"""

import argparse
import os
import re

def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-b', '--builddir', help='The directory where to place the produced output', required=True)
    parser.add_argument('-m', '--module', help='The module to parse', required=True)
    return vars(parser.parse_args())

def write_line(f, line):
    if len(line) > 2:
        f.write(line[2:])
    else:
        f.write('\n')

def read_module(args=get_args()):
    modname = os.path.splitext(os.path.basename(args['module']))[0]
    modpath = os.path.join(args['builddir'], 'modules')
    if not os.path.exists(modpath):
        os.makedirs(modpath)
    modfile = os.path.join(modpath, modname + '.rst')
    with open(args['module'], 'r') as i:
        o = open(modfile, 'w')
        # Write the first block into the module rst file
        o.write(".. _" + modname + ":\n\n")
        o.write(modname + "\n")
        o.write("="*len(modname) + "\n\n")

        for l in i:
            if not l.startswith('#'):
                o.close()
                return
            if l.startswith('# .. cmake_function'):
                o.close()
                cmdpath = os.path.join(args['builddir'], 'commands')
                if not os.path.exists(cmdpath):
                    os.makedirs(cmdpath)
                cmd = re.findall(r'# .. cmake_function:: (.*)', l)[0]
                cmdfile = os.path.join(cmdpath, cmd + ".rst")
                o = open(cmdfile, 'w')
                o.write(".. _" + cmd + ":\n\n")
                o.write(cmd + "\n")
                o.write("="*len(cmd) + "\n\n")
                write_line(o, l)
            elif l.startswith('# .. cmake_variable'):
                o.close()
                varpath = os.path.join(args['builddir'], 'variables')
                if not os.path.exists(varpath):
                    os.makedirs(varpath)
                var = re.findall(r'# .. cmake_variable:: (.*)', l)[0]
                varfile = os.path.join(varpath, var + ".rst")
                o = open(varfile, 'w')
                o.write(".. _" + var + ":\n\n")
                o.write(var + "\n")
                o.write("="*len(var) + "\n\n")
                write_line(o, l)
            else:
                write_line(o, l)

# Parse the given arguments
read_module()