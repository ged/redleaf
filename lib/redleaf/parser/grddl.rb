#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/parser'

# A parser for GRDDL (Gleaning Resource Descriptions from Dialects of Languages) 
# 
# == Subversion Id
#
#  $Id$
# 
# == Authors
# 
# * Michael Granger <ged@FaerieMUD.org>
# * Mahlon Smith <mahlon@martini.nu>
# 
# :include: LICENSE
#
#---
#
# Please see the file LICENSE in the BASE directory for licensing details.
#
class Redleaf::GRDDLParser < Redleaf::Parser

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	# Use the 'grddl' Redland parser
	parser_type :grddl
	

end # class Redleaf::GRDDLParser

# vim: set nosta noet ts=4 sw=4:

