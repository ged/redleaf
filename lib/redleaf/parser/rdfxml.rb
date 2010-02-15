#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/parser'

# A parser for the RDF+XML syntax.
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
class Redleaf::RDFXMLParser < Redleaf::Parser


	# Use the 'rdfxml' Redland parser
	parser_type :rdfxml
	

end # class Redleaf::RDFXMLParser

# vim: set nosta noet ts=4 sw=4:

