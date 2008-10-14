#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/mixins'

# An RDF parser object class
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
class Redleaf::Parser
	include Redleaf::Loggable

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Set the class's Redland parser type to +new_setting+ if given, and return the current
	### (new) setting.
	def self::parser_type( new_setting=nil )
		if new_setting
			Redleaf.logger.debug "Setting backend for %p to %p" % [ self, new_setting ]
			@parser_type = new_setting

			unless self.features.key?( @parser_type.to_s )
				Redleaf.logger.warn "local Redland library doesn't have %p parser; valid values are: %p" %
					[ @parser_type.to_s, self.features ]
			end
		end

		
		return @parser_type
	end
	
	
	### Get the parser_type for the class after making sure it's valid and supported by
	### the local installation. Raises a Redleaf::FeatureError if there is a problem.
	def self::validated_parser_type
		raise Redleaf::FeatureError, "unsupported parser type %p" % [ self.parser_type ] unless
		 	self.is_supported?
		
		return self.parser_type.to_s.gsub( /_/, '-' )
	end
	


	### Returns +true+ if the Redland parser type required by the receiving store class is
	### supported by the local installation.
	def self::is_supported?
		return self.features.include?( self.parser_type.to_s )
	end
	

end # class Redleaf::Parser

# vim: set nosta noet ts=4 sw=4:

