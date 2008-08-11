#!/usr/bin/env ruby
 
require 'uri'
require 'pathname'

require 'redleaf'


# A convenience class for building Redleaf::Resource objects.
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
class Redleaf::Namespace

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	### Set up a namespace for the specified +uri+.
	def initialize( uri )
		@uri = uri.is_a?( URI ) ? uri : URI.parse( uri )
	end


	######
	public
	######

	# The base URI of the namespace
	attr_reader :uri


	### Return the Redleaf::Namespace as a String
	def to_s
		@uri.to_s
	end


	### Return a fully-qualified URI for the specified +term+ relative to the namespace.
	def []( term )
		term_uri = self.uri.dup
		term_uri.path += term
		
		return term_uri
	end
	
end # class Redleaf::Namespace


