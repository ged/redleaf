#!/usr/bin/env ruby

require 'pathname'
 
require 'redleaf'
require 'redleaf/store'
require 'redleaf/mixins'

# A Redleaf::Store that uses PostgreSQL. This module is based on the MySQL
# store and is compiled in when PostgreSQL is available. This store provides
# storage using the PostgreSQL open source database including contexts.
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
class Redleaf::PostgreSQLStore < Redleaf::Store
	include Redleaf::HashUtilities

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$

	# Default options -- the PostgreSQL backend requires that all of them be set,
	# even if they're empty.
	DEFAULT_OPTIONS = {
		:new      => true,
		:database => 'test',
		:host     => 'localhost',
		:port     => '5432',
		:user     => 'test', 
		:password => '',
		:contexts => true,
	}

	# Use the 'postgresql' Redland backend
	backend :postgresql


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Load the PostgreSQL-backed Redleaf::HashesStore from the specified +database+.
	def self::load( database, opthash={} )
		return new( database, opthash.merge(:new => false) )
	end
	
	
	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	### Create a new Redleaf::PostgreSQLStore. 
	def initialize( name, opthash={} )
		opthash = symbolify_keys( opthash )
		self.log.debug "Symbolified keys: %p" % [ opthash ]
		options = DEFAULT_OPTIONS.merge( opthash )
		
		self.log.debug "Merged options are: %p" % [ options ]
		return super( name, options )
	end


	### Returns +true+ if the Store is persistent
	def persistent?
		return true
	end
	

end # class Redleaf::PostgreSQLStore

# vim: set nosta noet ts=4 sw=4:

