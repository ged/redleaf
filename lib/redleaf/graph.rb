#!/usr/bin/env ruby
 
require 'uri'
require 'redleaf'
require 'redleaf/mixins'

# An RDF graph class
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
class Redleaf::Graph
	include Redleaf::Loggable

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$



	######
	public
	######

	### Equivalence method -- two Redleaf::Graphs are equivalent if the graphs they represent are 
	### equivalent according to the Graph Equivalence rules of:
	###   http://www.w3.org/TR/2004/REC-rdf-concepts-20040210/#section-graph-equality
	def eql?( other_graph )
		return false unless other_graph.is_a?( Redleaf::Graph )
		return ( self ^ other_graph ).empty?
	end
	alias_method :==, :eql?
	
	
	### Set XOR: Return the set of statements that are exclusive to either the receiver 
	### or +other_graph+ (the union of their complements).
	def ^( other_graph )
		( self.statements | other_graph.statements ) - ( self.statements & other_graph.statements )
	end
	
	

end # class Redleaf::Graph

# vim: set nosta noet ts=4 sw=4:

