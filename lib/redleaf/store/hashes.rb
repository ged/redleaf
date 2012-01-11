#!/usr/bin/env ruby

require 'pathname'

require 'redleaf'
require 'redleaf/store'

# A Redleaf::Store that uses Redland's 'hashes' store. This store "provides
# indexed storage using Redland Triple stores to store various combinations of
# subject, predicate and object for faster access."
#
# This store comes in two flavors: the in-memory store, and bdb file storage.
#
# == Subversion Id
#
#  $Id$
#
# == Authors
#
# * Michael Granger <ged@FaerieMUD.org>
# * Mahlon E. Smith <mahlon@martini.nu>
#
# :include: LICENSE
#
#--
#
# Please see the file LICENSE in the BASE directory for licensing details.
#
class Redleaf::HashesStore < Redleaf::Store
	include Redleaf::Loggable

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

	### Normalize +options+ into a options hash that is appropriate for Redland
	### given an optional +name+ path.
	### @return [Array]  an array of +name+ and a normalized +options+ hash.
	def self::normalize_options( name=nil, options={} )
		if name.is_a?( Hash )
			options.merge!( name )
			name = nil
		end

		if name.nil?
			raise Redleaf::Error, "You must specify a name argument for the bdb hash type." if
				options[:hash_type] == :bdb
			options[:hash_type] = :memory

		elsif options[:hash_type] != :memory
			path = Pathname.new( options[:dir] || '.' ) + Pathname.new( name )

			options[:dir] = path.dirname.to_s
			options[:hash_type] = :bdb
			name = path.basename.to_s
		end

		Redleaf.logger.debug "Constructing a %p with name = %p, options = %p" % 
			[ self.name, name, options ]
		return name, options
	end


	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	### Create a new Redleaf::HashesStore, optionally enabling contexts.
	def initialize( name=nil, options={} )
		name, opts = self.class.normalize_options( name, options )
		opthash = DEFAULT_OPTIONS.merge( opts )

		@hash_type = opthash[:hash_type]

		return super( name.to_s, opthash )
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

