#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/store'

# An in-memory RDF triplestore (uses Redland's 'memory' store)
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
class Redleaf::MemoryStore < Redleaf::Store


	# Use the 'memory' Redland backend
	backend :memory
	

	### Create a new Redleaf::MemoryStore, optionally enabling contexts.
	def initialize( name=nil, enable_contexts=true )
		super( name, :contexts => enable_contexts ? 'yes' : 'no' )
	end
	

end # class Redleaf::MemoryStore

# vim: set nosta noet ts=4 sw=4:

