from __future__ import absolute_import
from dune.common.parametertree.parser import parse_ini_file


def test_parser(dir):
    parsed = parse_ini_file(dir + "parse.ini")
    assert(len(parsed) == 8)
    assert(parsed['x'] == '5')
    assert(parsed['y'] == 'str')
    assert(parsed['group.y'] == 'str')
    assert(parsed['group.x'] == '5')
    assert(parsed['group.z'] == '1')
    assert(parsed['group.subgroup.y'] == 'str')
    assert(parsed['group.subgroup.z'] == '1')
