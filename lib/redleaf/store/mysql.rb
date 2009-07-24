#!/usr/bin/env ruby

require 'pathname'

require 'redleaf'
require 'redleaf/store'

# A Redleaf::Store that uses MySQL. This module is compiled in to Redland when
# MySQL 3 or 4 is available. This store provides storage using the MySQL open
# source database including contexts. It was added in Redland 0.9.15. It has
# however been tested with several million triples and deployed.
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
class Redleaf::MySQLStore < Redleaf::Store

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$

	# Default options
	DEFAULT_OPTIONS = {
		:new      => true,
		:host     => 'localhost',
		:database => 'test',
		:user     => 'test',
		:password => '',
	}

	# Use the 'mysql' Redland backend
	backend :mysql


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Load the MySQL-backed Redleaf::HashesStore from the RDF graph of the specified
	### +name+.
	def self::load( name, opthash={} )
		opthash[:new] = false
		return new( name, opthash )
	end


	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	### Create a new Redleaf::MySQLStore. 
	def initialize( name, opthash={} )
		options = DEFAULT_OPTIONS.merge( opthash )
		return super( name, options )
	end


	### Returns +true+ if the Store is persistent
	def persistent?
		return true
	end


end # class Redleaf::MemoryStore

# vim: set nosta noet ts=4 sw=4:

