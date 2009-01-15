#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/parser'

# A parser for the TriG - Turtle with Named Graphs syntax.
# 
# The parser is alpha quality and may not support the entire TRiG specification.
#	
# == Subversion Id
#
#	$Id$
#	
# == Authors
#	
# * Michael Granger <ged@FaerieMUD.org>
#	
# :include: LICENSE
#
#---
#
# Please see the file LICENSE in the BASE directory for licensing details.
#
class Redleaf::TriGParser < Redleaf::Parser

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	# Use the 'trig' Redland parser
	parser_type :trig
	

end # class Redleaf::TriGParser

# vim: set nosta noet ts=4 sw=4:

