#!/usr/bin/env ruby

require 'pathname'
 
require 'redleaf'
require 'redleaf/store'

# A Redleaf::Store that uses Redland's 'hashes' store. This store "provides
# indexed storage using Redland Triple stores to store various combinations of
# subject, predicate and object for faster access."
#
# This store comes in two flavors: the in-memory store, and 
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
class Redleaf::HashesStore < Redleaf::Store

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$

	# Default options hash
	DEFAULT_OPTIONS = {
		:new       => true,
		:hash_type => :memory,
	}


	# Use the 'hashes' Redland backend
	backend :hashes


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Load the BDB-backed Redleaf::HashesStore from the specified +path+.
	def self::load( path, options={} )
		options.merge!( :new => false )
		return new( path, options )
	end
	
	
	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	### Create a new Redleaf::HashesStore, optionally enabling contexts.
	def initialize( name=nil, options={} )
		opthash = DEFAULT_OPTIONS.merge( options )

		if name.is_a?( Hash )
			opthash.merge!( name )
			name = nil
		end
		
		if name.nil?
			opthash[:hash_type] = @hash_type = :memory
		else
			path = Pathname.new( name )
			opthash[:dir] = path.dirname
			opthash[:hash_type] = @hash_type = :bdb
			name = path.basename
		end
		
		self.log.debug "Constructing a %p with name = %p, options = %p" % 
			[ self.class.name, name, opthash ]
		return super( name, opthash )
	end


	######
	public
	######

	# The store's hash type (either :memory or :bdb).
	attr_reader :hash_type


	### Returns +true+ if the Store is persistent (i.e., its hash_type is :bdb).
	def persistent?
		return self.hash_type == :bdb
	end
	

end # class Redleaf::MemoryStore

# vim: set nosta noet ts=4 sw=4:

