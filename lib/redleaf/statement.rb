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


	### Transform the given object to a node.
	def object_to_node( object )
	
		case object
		when URL, NilClass
			object
		else
			# Figure out what else to return
		end
	end
	


	### Equivalence method -- two Redleaf::Statements are equivalent if their subject and object
	### nodes are equivalent according to the bijective function described in:
	###   http://www.w3.org/TR/2004/REC-rdf-concepts-20040210/#section-graph-equality
	### and they have the same predicate.
	def eql?( other_statement )
		
	end
	

end # class Redleaf::Statement

# vim: set nosta noet ts=4 sw=4:

