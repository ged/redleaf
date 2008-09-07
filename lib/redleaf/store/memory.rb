#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/store'

# An in-memory RDF triplestore (uses Redland's 'memory' store)
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
class Redleaf::MemoryStore < Redleaf::Store

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	# Use the 'memory' Redland backend
	backend :memory
	

	### Create a new Redleaf::MemoryStore, optionally enabling contexts.
	def initialize( enable_contexts=true )
		super( :contexts => enable_contexts )
	end
	

end # class Redleaf::MemoryStore

# vim: set nosta noet ts=4 sw=4:

