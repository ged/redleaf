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
# * Mahlon Smith <mahlon@martini.nu>
#	
# :include: LICENSE
#
#---
#
# Please see the file LICENSE in the BASE directory for licensing details.
#
class Redleaf::Statement
	include Redleaf::Loggable,
	        Redleaf::Constants::CommonNamespaces,
	        Redleaf::NodeConversion

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$

end # class Redleaf::Statement

# vim: set nosta noet ts=4 sw=4:

