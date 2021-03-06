#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/queryresult'

# A result from a SPARQL query that returns a yes or no answer.
# 
# == Version-Control Id
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
class Redleaf::BooleanQueryResult < Redleaf::QueryResult


	######
	public
	######

	### Returns +true+ if the query result was true.
	def is_true?
		return self.value == true
	end


	### Returns +true+ if the query result was not true.
	def is_false?
		return !self.is_true?
	end
	

	### Call the block once if the query was true, yielding the +true+ value.
	def each # :yields: true
		yield( true ) if self.is_true?
	end

end # class Redleaf::BooleanQueryResult

# vim: set nosta noet ts=4 sw=4:

