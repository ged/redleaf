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
# * Mahlon Smith <mahlon@martini.nu>
# 
# :include: LICENSE
#
#---
#
# Please see the file LICENSE in the BASE directory for licensing details.
#
class Redleaf::HashesStore < Redleaf::Store

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	# Use the 'hashes' Redland backend
	backend :hashes


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Load the BDB-backed Redleaf::HashesStore from the specified +path+.
	def self::load( path )
		path = Pathname.new( path )
		
		options = {
			:new => false,
			:dir => path.dirname,
			:hash_type => 'bdb',
		}
		
		return new( path.basename, options )
	end
	
	
	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	### Create a new Redleaf::MemoryStore, optionally enabling contexts.
	def initialize( name=nil, options={} )
		if name.nil?
			@hash_type = :memory
		else
			@hash_type = :bdb
		end
		
		options[:new] = true if options[:new].nil?
		options[:hash_type] = @hash_type
		
		return super( name, options )
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

