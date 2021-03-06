#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/parser'

# A parser for GRDDL (Gleaning Resource Descriptions from Dialects of Languages) 
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
class Redleaf::GRDDLParser < Redleaf::Parser

	# Use the 'grddl' Redland parser
	parser_type :grddl


	### Parse the specified +content+ in the context of the specified +baseuri+. This parser 
	### requires a +baseuri+ argument.
	def parse( content, baseuri )
		super
	end

end # class Redleaf::GRDDLParser

# vim: set nosta noet ts=4 sw=4:

