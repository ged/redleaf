#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/queryresult'

# A result from a SPARQL query that returns a graph.
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
class Redleaf::GraphQueryResult < Redleaf::QueryResult

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	######
	public
	######

	### Iterate over the result's graph, yielding a Redleaf::Statement to the block for
	### each resulting statement.
	def each( &block ) # :yields: statement
		return self.graph.each( &block )
	end


	### Overloaded, as the JSON spec only has special formats for the binding and boolean
	### results types. This returns the result graph serialized as JSON instead.
	def to_json
		return self.graph.to_json
	end
	

	### Overloaded to return the result's graph as RDF/XML.
	def to_xml
		return self.graph.to_rdfxml_abbrev
	end
	
end # class Redleaf::GraphQueryResult

# vim: set nosta noet ts=4 sw=4:

