#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/mixins'
require 'redleaf/exceptions'

# An RDF triplestore abstract base class
# 
# == Version-Control Id
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
class Redleaf::Store
	include Redleaf::Loggable


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	@derivatives = {}
	class << self
		# Class attribute: a Hash of loaded concrete Redleaf::Store classes keyed by
		# name. E.g,. the Redleaf::HashesStore would be associated with the 'hashes' 
		# key. See the Redleaf::Store.backends hash for storage types supported in
		# the current environment.
		attr_reader :derivatives
	end

	
	### Register the given +subclass+ as being implemented by the specified +backend+.
	def self::register( subclass, backend )
		Redleaf.logger.debug "Registering %p as the %p backend" % [ subclass, backend ]
		@derivatives[ backend.to_sym ] = subclass
	end
	

	### Set the class's Redland backend to +new_setting+ if given, and return the current
	### (new) setting.
	def self::backend( new_setting=nil )
		if new_setting
			Redleaf.logger.debug "Setting backend for %p to %p" % [ self, new_setting ]
			@backend = new_setting
			Redleaf::Store.register( self, @backend )

			unless self.is_supported?
				Redleaf.logger.warn "local Redland library doesn't have the %p store; valid values are: %p" %
					[ @backend.to_s, self.backends.keys ]
			end
		end

		return @backend
	end
	
	
	### Get the backend name for the class after making sure it's valid and supported by
	### the local installation. Raises a Redleaf::FeatureError if there is a problem.
	def self::validated_backend
		raise Redleaf::FeatureError, "unsupported backend %p" % [ self.backend ] unless
		 	self.is_supported?
		
		return self.backend
	end
	


	### Returns +true+ if the Redland backend required by the receiving store class is
	### supported by the local installation.
	def self::is_supported?( storetype=nil )
		if storetype
			return self.backends.include?( storetype.to_s )
		else
			return self.backends.include?( self.backend.to_s )
		end
	end
	class << self
		alias_method :supported?, :is_supported?
	end


	### Make a Redland-style opthash pair String out of the specified key/value +pair+.	
	def self::make_optpair( *pair )
		key, value = *(pair.flatten)
		name = key.to_s.gsub( /_/, '-' )
		value = case value
		        when FalseClass
		        	'no'
		        when TrueClass
		        	'yes'
		        when NilClass
		        	''
		        else
		        	value
		        end
		
		return "%s='%s'" % [ name, value ]
	end
	

	### Make a librdf_hash-style optstring from the given +opthash+ and return it.
	def self::make_optstring( opthash )
		Redleaf.logger.debug "Making an optstring from hash: %p" % [ opthash ]
		filter = self.method( :make_optpair )
		optstring = opthash.collect( &filter ).join( ', ' )
		Redleaf.logger.debug "  optstring is: %p" % [ optstring ]
		
		return optstring
	end


	### Attempt to load the Redleaf::Store concrete class that wraps the given +backend+, create
	### one with the specified +args+, and return it.
	def self::create( backend, *args )
		require "redleaf/store/#{backend}"
		subclass = self.derivatives[ backend.to_sym ] or
			raise "Ack! Loading the %p backend didn't register a subclass." % [ backend ]
		
		return subclass.new( *args )
	end
	
	
	### Attempt to load the Redleaf::Store concrete class that wraps the given +backend+, load
	### one (via its ::load method) with the specified +args+, and return it.
	def self::load( backend, *args )
		require "redleaf/store/#{backend}"
		subclass = self.derivatives[ backend.to_sym ] or
			raise "Ack! Loading the %p backend didn't register a subclass." % [ backend ]
		
		return subclass.load( *args )
	end
	
	
	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	### Returns +true+ if the Store persists after the process has exited.
	def persistent?
		return false
	end


	### Return a human-readable representation of the object suitable for debugging.
	def inspect
		return "#<%s:0x%x name: %s, options: %p, graph: %p>" % [
			self.class.name,
			self.class.object_id * 2,
			self.name,
			self.opthash,
			self.graph,
		]
	end
	

end # class Redleaf::Store

# vim: set nosta noet ts=4 sw=4:

