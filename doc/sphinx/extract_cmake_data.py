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


def extract_rst(file, block):
    with open(file, 'r') as f:
        for i, l in enumerate(f):
            if i >= block[0] and i<block[1]:
                if len(l)>2:
                    yield l[2:]
                else:
                    yield '\n'
        
        
def extract_line(file, linenumber):
    with open(file, 'r') as f:
        for i, l in enumerate(f):
            if i == linenumber:
                return l

def read_module(args=get_args()):
    # determine the comment blocks
    blocks = []
    start = -1
    with open(args['module'], 'r') as f:
        for i, line in enumerate(f):
            if start == -1:
                if line.startswith('#'):
                    start = i
            else:
                if not line.startswith('#'):
                    blocks.append((start, i))
                    start = -1

    modname = os.path.splitext(os.path.basename(args['module']))[0]
    modpath = os.path.join(args['builddir'], 'modules')
    if not os.path.exists(modpath):
        os.makedirs(modpath)
    modfile = os.path.join(modpath, modname + '.rst')
    with open(modfile, 'w') as o:
        o.write(".. _" + modname + ":\n\n")
        o.write(modname + "\n")
        o.write("="*len(modname) + "\n")
        o.write("\n")
        for l in extract_rst(args['module'], blocks[0]):
            o.write(l)
        if len(blocks)>1:
            o.write("\nThis module defines the following commands:\n\n")
            o.write(".. toctree::\n")
            o.write("   :maxdepth: 1\n\n")
    
    for i in range(len(blocks))[1:]:
        # Now check all other blocks whether they do define commands.
        func = re.findall(r'function\((.*)\)', extract_line(args['module'], blocks[i][1]))
        macro = re.findall(r'macro\((.*)\)', extract_line(args['module'], blocks[i][1]))
        commandname = None
        if func:
            commandname = func[0].split()[0]
        if macro:
            commandname = macro[0].split()[0]
        # If a command is defined, extract its documentation:
        if commandname:
            cmdpath = os.path.join(args['builddir'], 'commands')
            if not os.path.exists(cmdpath):
                os.makedirs(cmdpath)
            cmdfile = os.path.join(cmdpath, commandname + ".rst")
            with open(cmdfile, 'w') as o:
                o.write(".. _" + commandname + ":\n\n")
                o.write(commandname + "\n")
                o.write("="*len(commandname) + "\n\n")
                for l in extract_rst(args['module'], blocks[i]):
                    o.write(l)
            with open(modfile, 'a') as o:
                o.write("   ../commands/" + commandname)
     

# Parse the given arguments
read_module()