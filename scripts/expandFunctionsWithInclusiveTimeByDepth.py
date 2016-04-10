#!/usr/bin/env python

"""
This tool re-uses the class Struct and GprofParser in gprof2dot.py
https://github.com/jrfonseca/gprof2dot.git
"""

from __future__ import division
import sys
import math
import re
import optparse
from collections import deque

# Python 2.x/3.x compatibility
if sys.version_info[0] >= 3:
    PYTHON_3 = True
    def compat_iteritems(x): return x.items()  # No iteritems() in Python 3
    def compat_itervalues(x): return x.values()  # No itervalues() in Python 3
    def compat_keys(x): return list(x.keys())  # keys() is a generator in Python 3
    basestring = str  # No class basestring in Python 3
    unichr = chr # No unichr in Python 3
    xrange = range # No xrange in Python 3
else:
    PYTHON_3 = False
    def compat_iteritems(x): return x.iteritems()
    def compat_itervalues(x): return x.itervalues()
    def compat_keys(x): return x.keys()


class Struct:
    """Masquerade a dictionary with a structure-like behavior."""

    def __init__(self, attrs = None):
        if attrs is None:
            attrs = {}
        self.__dict__['_attrs'] = attrs

    def __getattr__(self, name):
        try:
            return self._attrs[name]
        except KeyError:
            raise AttributeError(name)

    def __setattr__(self, name, value):
        self._attrs[name] = value

    def __str__(self):
        return str(self._attrs)

    def __repr__(self):
        return repr(self._attrs)


class GprofParser():
    """Parser for GNU gprof output.

    See also:
    - Chapter "Interpreting gprof's Output" from the GNU gprof manual
      http://sourceware.org/binutils/docs-2.18/gprof/Call-Graph.html#Call-Graph
    - File "cg_print.c" from the GNU gprof source code
      http://sourceware.org/cgi-bin/cvsweb.cgi/~checkout~/src/gprof/cg_print.c?rev=1.12&cvsroot=src
    """

    def __init__(self, fp, show_name):
        #Parser.__init__(self)
        self.fp = fp
        self.functions = {}
        self.cycles = {}
        self.threshold = None
        self.show_name = show_name

    def readline(self):
        line = self.fp.readline()
        if not line:
            sys.stderr.write('error: unexpected end of file\n')
            sys.exit(1)
        line = line.rstrip('\r\n')
        return line

    _int_re = re.compile(r'^\d+$')
    _float_re = re.compile(r'^\d+\.\d+$')

    def translate(self, mo):
        """Extract a structure from a match object, while translating the types in the process."""
        attrs = {}
        # Return a dictionary containing all the named subgroups of the match, keyed by the subgroup name.
        groupdict = mo.groupdict()
        for name, value in compat_iteritems(groupdict):
            if value is None:
                value = None
            elif self._int_re.match(value):
                value = int(value)
            elif self._float_re.match(value):
                value = float(value)
            attrs[name] = (value)
        return Struct(attrs)

    _cg_header_re = re.compile(
        # original gprof header
        r'^\s+called/total\s+parents\s*$|' +
        r'^index\s+%time\s+self\s+descendents\s+called\+self\s+name\s+index\s*$|' +
        r'^\s+called/total\s+children\s*$|' +
        # GNU gprof header
        r'^index\s+%\s+time\s+self\s+children\s+called\s+name\s*$'
    )

    _cg_ignore_re = re.compile(
        # spontaneous
        r'^\s+<spontaneous>\s*$|'
        # internal calls (such as "mcount")
        r'^.*\((\d+)\)$'
    )

    _cg_primary_re = re.compile(
        r'^\[(?P<index>\d+)\]?' +
        r'\s+(?P<percentage_time>\d+\.\d+)' +
        r'\s+(?P<self>\d+\.\d+)' +
        r'\s+(?P<descendants>\d+\.\d+)' +
        r'\s+(?:(?P<called>\d+)(?:\+(?P<called_self>\d+))?)?' +
        r'\s+(?P<name>\S.*?)' +
        r'(?:\s+<cycle\s(?P<cycle>\d+)>)?' +
        r'\s\[(\d+)\]$'
    )

    _cg_parent_re = re.compile(
        r'^\s+(?P<self>\d+\.\d+)?' +
        r'\s+(?P<descendants>\d+\.\d+)?' +
        r'\s+(?P<called>\d+)(?:/(?P<called_total>\d+))?' +
        r'\s+(?P<name>\S.*?)' +
        r'(?:\s+<cycle\s(?P<cycle>\d+)>)?' +
        r'\s\[(?P<index>\d+)\]$'
    )

    _cg_child_re = _cg_parent_re

    _cg_cycle_header_re = re.compile(
        r'^\[(?P<index>\d+)\]?' +
        r'\s+(?P<percentage_time>\d+\.\d+)' +
        r'\s+(?P<self>\d+\.\d+)' +
        r'\s+(?P<descendants>\d+\.\d+)' +
        r'\s+(?:(?P<called>\d+)(?:\+(?P<called_self>\d+))?)?' +
        r'\s+<cycle\s(?P<cycle>\d+)\sas\sa\swhole>' +
        r'\s\[(\d+)\]$'
    )

    _cg_cycle_member_re = re.compile(
        r'^\s+(?P<self>\d+\.\d+)?' +
        r'\s+(?P<descendants>\d+\.\d+)?' +
        r'\s+(?P<called>\d+)(?:\+(?P<called_self>\d+))?' +
        r'\s+(?P<name>\S.*?)' +
        r'(?:\s+<cycle\s(?P<cycle>\d+)>)?' +
        r'\s\[(?P<index>\d+)\]$'
    )

    _cg_sep_re = re.compile(r'^--+$')

    def parse_function_entry(self, lines):
        parents = []
        children = []

        while True:
            if not lines:
                sys.stderr.write('warning: unexpected end of entry\n')
            line = lines.pop(0)
            # only the primary line starts with '['
            if line.startswith('['):
                break

            # read function parent line
            mo = self._cg_parent_re.match(line)
            if not mo:
                # ignore lines "<spontaneous> ..."
                if self._cg_ignore_re.match(line):
                    continue
                sys.stderr.write('warning: unrecognized call graph entry: %r\n' % line)
            else:
                parent = self.translate(mo)
                # parents save all the entries, each entry contains params "self call" etc.
                parents.append(parent)

        # read primary line
        # note that it is already popped from lines
        mo = self._cg_primary_re.match(line)

        if not mo:
            sys.stderr.write('warning: unrecognized call graph entry: %r\n' % line)
            return
        else:
            function = self.translate(mo)

        while lines:
            line = lines.pop(0)

            # read function subroutine line
            mo = self._cg_child_re.match(line)
            if not mo:
                if self._cg_ignore_re.match(line):
                    continue
                sys.stderr.write('warning: unrecognized call graph entry: %r\n' % line)
            else:
                child = self.translate(mo)
                children.append(child)

        function.parents = parents
        function.children = children

        self.functions[function.index] = function

    def parse_cycle_entry(self, lines):

        # read cycle header line
        line = lines[0]
        mo = self._cg_cycle_header_re.match(line)
        if not mo:
            sys.stderr.write('warning: unrecognized call graph entry: %r\n' % line)
            return
        # the Struct
        # in callgraph:
        # [18]    25.6   30.70    1.62 2063230471+1000861014 <cycle 2 as a whole> [18]
        # {'index': 18, 'descendants': 1.62, 'self': 30.7, 'percentage_time': 25.6, 'cycle': 2, 'called': 2063230471, 'called_self': 1000861014}
        cycle = self.translate(mo)

        # read cycle member lines
        # append all functions in cycle entry
        cycle.functions = []
        # append all children
        for line in lines[1:]:
            mo = self._cg_cycle_member_re.match(line)
            if not mo:
                sys.stderr.write('warning: unrecognized call graph entry: %r\n' % line)
                continue
            call = self.translate(mo)
            cycle.functions.append(call)
        # cycle.cycle is the cycle number
        self.cycles[cycle.cycle] = cycle

    def parse_cg_entry(self, lines):
        if lines[0].startswith("["):
            # example in callgraph: [18]    25.6   30.70    1.62 2063230471+1000861014 <cycle 2 as a whole> [18]
            self.parse_cycle_entry(lines)
        else:
            self.parse_function_entry(lines)

    def parse_cg(self):
        """Parse the call graph."""

        # skip call graph header
        # ignore the starting lines that is not graph header
        while not self._cg_header_re.match(self.readline()):
            pass
        line = self.readline()
        while self._cg_header_re.match(line):
            line = self.readline()

        # process call graph entries
        entry_lines = []
        while line != '\014': # form feed
            if line and not line.isspace():
                if self._cg_sep_re.match(line):
                    # entry_lines saves the lines for last entry
                    # we process it here
                    self.parse_cg_entry(entry_lines)
                    # reset entry_lines
                    entry_lines = []
                else:
                    # append normal lines, if we have an sep_re
                    # we can process it in the above code
                    entry_lines.append(line)
            line = self.readline()

    def isChild(self, parent, func):
        for item in self.functions[parent].children:
            if item.index == func:
                return True
        return False

    def isParentOfNfdModule(self, func):
        nextFunc = [func]
        while (len(nextFunc) != 0):
            index = nextFunc.pop()
            if not index in self.functions:
                return False
            if "nfd" in self.functions[index].name:
                return True
            for childFunc in self.functions[index].children:
                if not childFunc.index in self.functions:
                    continue
                child = self.functions[childFunc.index]
                # break the cycle (A->B->C-A), but loss some details
                if child.cycle == None and child.called_self == None:
                    nextFunc.append(child.index)
        return False


    def expandFunctionsWithInclusiveTime(self):
        # function entry example:
        #(1387, {'index': 1387, 'name': '__tcf_0', 'descendants': 0.0, 'self': 0.0, 'percentage_time': 0.0, 'children': [], 'parents': [{'called_total': 1, 'index': 1180, 'name': 'nfd::rib::RibStatusPublisher::RibStatusPublisher(nfd::rib::Rib const&, ndn::Face&, ndn::Name const&, ndn::security::KeyChain&)', 'descendants': 0.0, 'self': 0.0, 'called': 1, 'cycle': None}], 'cycle': None, 'called': 1, 'called_self': None})
        sortedIndex = sorted(self.functions)
        
        # use list as stack
        toBeVisited = []

        # ignore the nfd::NfdRunner::run() and nfd::NfdRunner::run()::{lambda()#1}::operator()() const for now
        # because they split the percentage time boost::asio::detail::task_io_service::run(boost::system::error_code&)

        # tranverse the graph without cycles
        # tuple members: (index, called, depth, list for which level contains a "|")
        toBeVisited.append((sortedIndex[0], self.functions[sortedIndex[0]].called, 0, []))

        # use a queue to save the nodes orderly, since we can save the index to add "|"
        visitOrder = deque()

        #called_self = []
        while (len(toBeVisited) != 0):
            tmp = toBeVisited.pop()
            (curFuncIndex, called, depth, sep_list) = tmp

            # if the index is not in the function dict, ignore
            if not curFuncIndex in self.functions.keys():
                continue
            curFunc = self.functions[curFuncIndex]

            if curFunc.name.startswith("_GLOBAL__sub_I__ZN3"):
                continue

            percentage_time = curFunc.percentage_time * (called/curFunc.called)

            # ignore function and its children whose percentage_time is smaller than threshold
            if self.threshold != None and percentage_time < self.threshold:
                continue

            # every time, before add an item, update the previous items till the same level
            for item in reversed(visitOrder):
                 if item[2] <= depth:
                     break
                 if not depth in item[3]:
                    # item[3] is the index that needs a '|'
                    item[3].append(depth)

            visitOrder.append(tmp)

            children = sorted(curFunc.children, key = lambda x: x.index, reverse=True)
            for childFunc in children:
                if not childFunc.index in self.functions:
                    continue

                # do not add self calls
                if self.functions[childFunc.index].called_self != None:
                    #if not childFunc.index in called_self:
                    #    called_self.append(childFunc.index)
                    continue

                # assuming that function name without "nfd" will not call nfd functions except that its child function contains it
                if not "nfd" in childFunc.name and not self.isParentOfNfdModule(childFunc.index):
                    continue
                else:
                    propagated_calls = childFunc.called * (called/curFunc.called)

                    toBeVisited.append((childFunc.index, propagated_calls, depth + 1, []))

        #print "\ncalled_self:", called_self
        #for item in called_self:
        #    print self.functions[item].percentage_time, self.functions[item].name, "[%s]"%item
        #print "\n"

        print "\nThe tree below lists functions, it does not go deeper when it touches a cycle\n"
        print "Note that each entry contains 3 components 'percentage_time', 'function_name', 'fucntion index in the original gprof file'\n\n"
        while (len(visitOrder) != 0):
            (index, calls, depth, sep_list) = visitOrder.popleft()

            if not index in self.functions.keys():
                continue
            curFunc = self.functions[index]

            # visitOrder should contains all functions(except the self-called function) in the call graph
            lvlStr = list()

            if depth > 0:
                # indent for better layout
                for i in range((depth - 1)*2): lvlStr.append(" ")
                # add "|" into the indentation so that users can locate the parent function
                for i in sep_list:
                    lvlStr[(i - 1)*2] = '|'
            funcStr = ""
            percentage_time = curFunc.percentage_time * (calls/curFunc.called)

            if depth > 0:
                lvlStr.append("|-")
            
            nextOne = -1
            if len(visitOrder) > 0:
                (nextOne, a, b, c) = visitOrder[0]

            if nextOne != -1 and self.isChild(index, nextOne):
                funcStr = "".join(lvlStr) + "+ "
            else:
                funcStr = "".join(lvlStr) + "- "

            if self.show_name:
                funcStr = funcStr + "%.2f"%percentage_time + "\t" + curFunc.name + "\t[%s]"%curFunc.index
            else:
                funcStr = funcStr + "%.2f"%percentage_time + "\t[%s]"%curFunc.index

            if curFunc.cycle != None:
                funcStr = funcStr + " <cycle %s>"%curFunc.cycle
            funcStr.strip()
            print funcStr

    def setThreshold(self, threshold):
        self.threshold = threshold
            
    def parse(self):
        self.parse_cg()
        self.fp.close()
        self.expandFunctionsWithInclusiveTime()
        #print self.functions[165], "\n"

def main():
    """Main program."""
    optparser = optparse.OptionParser(
        usage="\n\t%prog [options]") 

    optparser.add_option(
        '-f', '--input', metavar='FILE',
        type="string", dest="input",
        help="input filename [stdin]")

    optparser.add_option(
        '-i', '--ignore', metavar='percentage_time',
        type="float", dest="threshold",
        help="ignore functions whose percentage time is below the threshold")

    optparser.add_option(
        "-n", action="store_false", dest="show_name",
        default=True, help="disable function name")

    (options, args) = optparser.parse_args(sys.argv[1:])

    fp = ""
    if options.input is None:
        fp = sys.stdin
    else:
        fp = open(options.input)

    parser = GprofParser(fp, options.show_name)

    if not options.threshold is None:
        parser.setThreshold(options.threshold)

    parser.parse()

if __name__ == '__main__':
    main()
