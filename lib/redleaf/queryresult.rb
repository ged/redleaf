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


	### Set the graph that the result belongs to
	def initialize( graph )
		@graph = graph
	end
	
	
	######
	public
	######

	# The Redleaf::Graph the result is from
	attr_reader :graph
	

end # class Redleaf::QueryResult

# vim: set nosta noet ts=4 sw=4:

