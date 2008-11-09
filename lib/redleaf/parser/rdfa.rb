#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/parser'

# A parser for RDF/A (http://www.w3.org/TR/rdfa-syntax/)
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
class Redleaf::RDFaParser < Redleaf::Parser

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	# Use the 'rdfa' Redland parser
	parser_type :rdfa
	

end # class Redleaf::RDFaParser

# vim: set nosta noet ts=4 sw=4:

