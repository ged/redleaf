#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/mixins'
require 'redleaf/exceptions'

# An RDF triplestore abstract base class
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
class Redleaf::Store
	include Redleaf::Loggable

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Set the class's Redland backend to +new_setting+ if given, and return the current
	### (new) setting.
	def self::backend( new_setting=nil )
		if new_setting
			Redleaf.logger.debug "Setting backend for %p to %p" % [ self, new_setting ]
			@backend = new_setting

			unless self.backends.key?( @backend.to_s )
				Redleaf.logger.warn "local Redland library doesn't have the %p store; valid values are: %p" %
					[ @backend.to_s, self.backends ]
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
	def self::is_supported?
		return self.backends.include?( self.backend.to_s )
	end
	

	### Make a librdf_hash-style optstring from the given +opthash+ and return it.
	def self::make_optstring( opthash )
		Redleaf.logger.debug "Making an optstring from hash: %p" % [ opthash ]
		optstring = opthash.collect {|k,v| "%s='%s'" % [k.to_s.gsub(/_/, '-'),v] }.join( ', ' )
		Redleaf.logger.debug "  optstring is: %p" % [ optstring ]
		
		return optstring
	end
	
	
	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	### Returns +true+ if the Store persists after the process has exited.
	def persistent?
		return false
	end
	

end # class Redleaf::Store

# vim: set nosta noet ts=4 sw=4:

