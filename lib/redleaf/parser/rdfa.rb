#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/parser'

# A parser for RDF/A (http://www.w3.org/TR/rdfa-syntax/)
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
class Redleaf::RDFaParser < Redleaf::Parser

	# Use the 'rdfa' Redland parser
	parser_type :rdfa

	### Parse the specified +content+ in the context of the specified +baseuri+. This parser 
	### requires a +baseuri+ argument.
	def parse( content, baseuri )
		super
	end

end # class Redleaf::RDFaParser

# vim: set nosta noet ts=4 sw=4:

