#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/parser'

# A parser for the NTriples RDF syntax.
# 
# == Subversion Id
#
#  $Id$
# 
# == Authors
# 
# * Michael Granger <ged@FaerieMUD.org>
# 
# :include: LICENSE
#
#--
#
# Please see the file LICENSE in the BASE directory for licensing details.
#
class Redleaf::NTriplesParser < Redleaf::Parser

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	# Use the 'ntriples' Redland parser
	parser_type :ntriples
	

end # class Redleaf::NTriplesParser

# vim: set nosta noet ts=4 sw=4:

