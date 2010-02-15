#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/parser'

# A parser for the NTriples RDF syntax.
# 
# == Version-Control Id
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


	# Use the 'ntriples' Redland parser
	parser_type :ntriples
	

end # class Redleaf::NTriplesParser

# vim: set nosta noet ts=4 sw=4:

