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
# 
# :include: LICENSE
#
#--
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
		@source_graph = graph
	end
	
	
	######
	public
	######

	# The Redleaf::Graph the result is from
	attr_reader :source_graph


	### Return the query result as JSON in the format specified by 
	### http://www.w3.org/2001/sw/DataAccess/json-sparql/.
	def to_json
		json = self.formatted_as( self.class.formatters['json'][:uri] )

		# Work around the doubled-quotes bug
		json.gsub!( %r{""(ordered|distinct)}, %{"\\1} )
		
		return json
	end
	

	### Return the query result as RDF/XML in the format specified by 
	### http://www.w3.org/2005/sparql-results.
	def to_xml
		return self.formatted_as( self.class.formatters['xml'][:uri] )
	end
	

	### Proxy method -- handle serialization format convenience calls like
	### #to_json, #to_xml, etc.
	def method_missing( sym, *args )
		super unless sym.to_s =~ /^to_(\w+)$/
		
		format = $1
		formatters = self.class.formatters
		unless formatters.key?( format )
			raise Redleaf::FeatureError,
				"local Redland installation does not have a '%s' formatter"
		end
		
		return self.formatted_as( formatters[format][:uri] )
	end
	
	
	require 'redleaf/queryresult/graph'
	require 'redleaf/queryresult/binding'
	require 'redleaf/queryresult/boolean'

end # class Redleaf::QueryResult

# vim: set nosta noet ts=4 sw=4:

