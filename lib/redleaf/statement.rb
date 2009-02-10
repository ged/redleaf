#!/usr/bin/env ruby

require 'redleaf' 
require 'redleaf/mixins'
require 'redleaf/utils'


# An RDF statement class. A statement is a node-arc-node triple (subject
# --predicate--> object). The subject can be either a URI or a blank node, the
# predicate is always a URI, and the object can be a URI, a blank node, or a
# literal.
#	
# == Subversion Id
#
#	$Id$
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
class Redleaf::Statement
	include Comparable,
	        Redleaf::Loggable,
	        Redleaf::Constants::CommonNamespaces,
	        Redleaf::NodeUtils

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	### Generates a Fixnum hash value for the statement, made up of the hash of its components.
	def hash
		return [ self.subject, self.predicate, self.object ].hash
	end
	
	
	### Comparable interface
	def <=>( other )
		return 0 unless other
		return ( self.subject.to_s <=> other.subject.to_s ).nonzero? ||
		       ( self.predicate.to_s <=> other.predicate.to_s ).nonzero? ||
		       ( self.object.to_s <=> other.object.to_s )
	end
	

end # class Redleaf::Statement

# vim: set nosta noet ts=4 sw=4:

