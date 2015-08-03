""" A cmake extension for Sphinx 

tailored for the Dune project.
"""

from docutils import nodes
from docutils.parsers.rst import Directive
from pygments.lexers.make import CMakeLexer
from sphinx.util.compat import make_admonition
from docutils.statemachine import StringList

class CMakeParamNode(nodes.Element):
    pass    

class CMakeFunction(Directive):
    # We do require the name to be an argument
    required_arguments = 1
    optional_arguments = 0
    final_argument_whitespace = False
    has_content = True
    
    def run(self):
        env = self.state.document.settings.env

        # Parse the content of the directive recursively
        node = nodes.Element()
        node.document = self.state.document
        self.state.nested_parse(self.content, self.content_offset, node)
        
        output_nodes = []
        required_params = {}
        optional_params = {}

        for child in node:
            if isinstance(child, CMakeParamNode):
                if child["required"]:
                    required_params[child["name"]] = child
                else:
                    optional_params[child["name"]] = child
            else:
                output_nodes.append(child)
                
        # Build the content of the box
        sl = [self.arguments[0] + '(\n']
        for rp in required_params:
            if rp["multi"]:
                sl.append(" "*(len(self.arguments[0])+2) + rp['name'] + ' ' + rp['argname'] + '1 [' + rp['argname'] + '2 ...]\n')
            if rp["single"]:
                sl.append(" "*(len(self.arguments[0])+2) + rp['name'] + ' ' + rp['argname'] + '\n')
            if rp["option"]:
                sl.append(" "*(len(self.arguments[0])+2) + rp['name'] + '\n')

        for op, paramnode in optional_params.items():
            if paramnode["multi"]:
                sl.append(' '*(len(self.arguments[0])+1) + '[' + paramnode['name'] + ' ' + paramnode['argname'] + '1 [' + paramnode['argname'] + '2 ...]' + ']\n')
            if paramnode["single"]:
                sl.append(" "*(len(self.arguments[0])+1) + '['+ paramnode['name'] + ' ' + paramnode['argname'] + ']\n')
            if paramnode["option"]:
                sl.append(" "*(len(self.arguments[0])+1) + '['+ paramnode['name'] + ']\n')
        
        sl.append(")\n")
        lb = nodes.literal_block(''.join(sl), ''.join(sl))
        output_nodes.append(lb)
 
        dl = nodes.definition_list()
        for param, paramnode in optional_params.items():
            dli = nodes.definition_list_item()
            dl += dli

            dlit = nodes.term(text=param)
            dli += dlit
            
            dlic = nodes.definition()
            dli += dlic
            self.state.nested_parse(paramnode['content'], self.content_offset, dlic)

        # add the parameter list to the output
        output_nodes.append(dl)

        return output_nodes
    
    
class CMakeParam(Directive):
    # We do require the name to be an argument
    required_arguments = 1
    optional_arguments = 0
    final_argument_whitespace = False
    option_spec = {'single': lambda s: True,
                   'multi': lambda s: True,
                   'option': lambda s: True,
                   'required': lambda s: True,
                   'argname' : lambda s: s}
    has_content = True
    
    def run(self):
        node = CMakeParamNode()
        # set defaults:
        assert(self.arguments[0] == self.arguments[0].upper())

        node['name'] = self.arguments[0]
        node['single'] = self.options.get('single', False)
        node['multi'] = self.options.get('multi', False)
        node['option'] = self.options.get('option', False)
        node['required'] = self.options.get('required', False)
        node['argname'] = self.options.get('argname', self.arguments[0].lower() if self.arguments[0].lower()[-1:] != 's' else self.arguments[0].lower()[:-1])
        node['content'] = self.content
        return [node]
        

# class CMakeCommand(Directive):
#     required_arguments = 1
# 
#     def run(self, obj):
#         target = nodes.target()
#         lineno = self.state_machine.abs_line_number()
#         self.state.add_target(self.arguments[0], '', target, lineno)
#         return [target]

# class CMakeDocParser(object):
#     def __init__(self, module='/home/dominic/dune/dune-python/cmake/modules/PythonVersion.cmake'):
#         self.module = module
#         self.blocks = {}
# 
#         # determine the comment blocks
#         self.blocks = []
#         start = -1
#         f = open(module, 'r')
#         for i, line in enumerate(f):
#             if start == -1:
#                 if line.startswith('#'):
#                     start = i
#             else:
#                 if not line.startswith('#'):
#                     self.blocks.append((start, i))
#                     start = -1
#     
#     def extract(self, start, end):
#         with open(self.module, 'r') as f:
#             for i, l in enumerate(f):
#                 if i >= start and i<end:
#                     yield l[2:]
#     
#     def get_block(self, number):
#         return [l for l in self.extract(self.blocks[number][0], self.blocks[number][1])]
# 
# 
# class cmake_module_node(nodes.Structural, nodes.Element):
#     pass
# 
# 
# def visit_cmake_module_node(self, node):
#     self.visit(node)
# #     self.visit_text(node)
# 
# 
# def depart_cmake_module_node(self, node):
#     self.visit(node)
#     pass
# #     self.depart_text(node)
# 
# 
# class CMakeModule(Directive):
#     required_arguments = 1
#     optional_arguments = 0
#     final_argument_whitespace = 0
#     has_content = False
#     
#     def __init__(self, *args, **kwargs):
#         Directive.__init__(self, *args, **kwargs)
#     
#     def run(self):
#         # extract the module and parse it
#         module = self.arguments[0]
#         parser = CMakeDocParser(module)
#         
#         # create a section
#         import os.path
#         modname = os.path.basename(module)
#         idm = nodes.make_id(modname)
#         section = nodes.section(ids=[idm])
#         
#         #
#         from docutils.statemachine import ViewList
#         l = ViewList(initlist=parser.get_block(0))
#         
#         from IPython import embed; embed()
#         
#         # Now parse the rst from the cmake module in nested fashion
#         par = nodes.paragraph()
#         self.state.nested_parse(l, self.content_offset, par)
#         
#         # create the resulting node
#         n = cmake_module_node()
#         n += section
#         n += par
# 
#         return [n]


def setup(app):
    print "CMake Extensions setup"
#     app.add_lexer('cmake', CMakeLexer())
    app.add_node(CMakeParamNode)
    app.add_directive('cmake_function', CMakeFunction)
    app.add_directive('cmake_param', CMakeParam)
#     app.add_node(cmake_module_node)#, html=(visit_cmake_module_node, depart_cmake_module_node))
#     app.add_directive("cmake_module", CMakeModule)
    
    return {'version': '0.1'}
