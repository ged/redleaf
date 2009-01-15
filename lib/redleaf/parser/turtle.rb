#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/parser'

# A parser for the Turtle Terse RDF Triple Language syntax, designed as a
# useful subset of Notation 3.
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
class Redleaf::TurtleParser < Redleaf::Parser

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	# Use the 'turtle' Redland parser
	parser_type :turtle
	

end # class Redleaf::TurtleParser

# vim: set nosta noet ts=4 sw=4:

