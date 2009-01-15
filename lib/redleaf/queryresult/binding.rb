#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/queryresult'

# A result from a SPARQL query that returns a series of rows with bound variables.
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
#---
#
# Please see the file LICENSE in the BASE directory for licensing details.
#
class Redleaf::BindingQueryResult < Redleaf::QueryResult

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	######
	public
	######

	### Iterate over the result's rows, yielding each one as a hash to the provided +block+.
	def each( &block ) # :yields: row
		return self.rows.each( &block )
	end

end # class Redleaf::BindingQueryResult

# vim: set nosta noet ts=4 sw=4:

