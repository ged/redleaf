#!/usr/bin/env ruby

require 'pathname'
 
require 'redleaf'
require 'redleaf/store'

# A Redleaf::Store that uses SQLite. 
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
class Redleaf::SQLiteStore < Redleaf::Store

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$

	# Default store options
	DEFAULT_OPTIONS = {
		:new => true,
	}


	# Use the 'sqlite' Redland backend
	backend :sqlite


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Load the SQLite-backed Redleaf::HashesStore from the specified +path+.
	def self::load( path )
		return new( path, :new => 'no' )
	end
	
	
	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	### Create a new Redleaf::SQLiteStore. If the optional +new_db+ flag is true, any existing
	### database is destroyed.
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

