#!/usr/bin/env ruby
 
require 'uri'

require 'redleaf'


# An RDF statement class. A statement is a node-arc-node triple (subject --predicate--> object). The
# subject can be either a URI or a blank node, the predicate is always a URI, and the object can
# be a URI, a blank node, or a literal.
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
#:include: LICENSE
#
#---
#
# Please see the file LICENSE in the BASE directory for licensing details.
#
class Redleaf::Statement

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	### Create a new Redleaf::Statement for the specified +subject+, +predicate+, and +object+.
	### A +nil+ as either the subject or object will be interpreted as a blank node.
	def initialize( subject, predicate, object )
		
	end
	

	### Equivalence method -- two Redleaf::Graphs are equivalent if the graphs they represent are 
	### equivalent according to the Graph Equivalence rules of:
	###   http://www.w3.org/TR/2004/REC-rdf-concepts-20040210/#section-graph-equality
	def eql?( other_statement )
		return false unless other_statement.is_a?( Redleaf::Statement )

		return true
	end
	alias_method :==, :eql?
	

end # class Redleaf::Graph

# vim: set nosta noet ts=4 sw=4:

