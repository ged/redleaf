#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/mixins'

# An abstract base class for encapsulating various kinds of query results.
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
class Redleaf::QueryResult
	include Redleaf::Loggable

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$

	# Disallow direct instantiation
	private_class_method :new

end # class Redleaf::QueryResult

# vim: set nosta noet ts=4 sw=4:

