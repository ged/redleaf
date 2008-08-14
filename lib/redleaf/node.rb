#!/usr/bin/env ruby
 
require 'uri'

require 'redleaf'


# An RDF node base class. A node can be used as either the subject or object of a Redleaf::Statement,
# and may be a literal (LiteralNode), a BlankNode, or contain a URI.
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
class Redleaf::Node

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


end # class Redleaf::Node

# vim: set nosta noet ts=4 sw=4:

