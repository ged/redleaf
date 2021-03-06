#!/usr/bin/env ruby

require 'redleaf'
require 'redleaf/mixins'

# An RDF parser object class
# 
# == Version-Control Id
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
class Redleaf::Parser
	include Redleaf::Loggable


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	@subclasses = []
	class << self; attr_reader :subclasses ; end


	### Inheritance callback -- keep track of all subclasses so we can search for them
	### by name later.
	def self::inherited( subclass )
		if self == Redleaf::Parser
			@subclasses << subclass
		end
		super
	end


	### Find a parser class by +name+.
	def self::find_by_name( name )
		begin
			require "redleaf/parser/#{name}"
		rescue LoadError => err
			Redleaf.logger.error "%s while trying to load a parser named %p: %s" %
				[ err.class.name, name, err.message ]
		end

		return self.subclasses.find {|klass| klass.parser_type.to_s == name }
	end


	### Set the class's Redland parser type to +new_setting+ if given, and return the current
	### (new) setting.
	def self::parser_type( new_setting=nil )
		if new_setting
			Redleaf.logger.debug "Setting backend for %p to %p" % [ self, new_setting ]
			@parser_type = new_setting.to_sym

			unless self.is_supported?
				Redleaf.logger.warn "local Redland library doesn't have %p parser; valid values are: %p" %
					[ @parser_type.to_s, self.features ]
			end
		end

		return @parser_type
	end


	### Get the parser_type for the class after making sure it's valid and supported by
	### the local installation. Raises a Redleaf::FeatureError if there is a problem.
	def self::validated_parser_type
		return self.parser_type.to_s.gsub( /_/, '-' )
	end


	### Returns +true+ if the Redland parser type required by the receiving store class is
	### supported by the local installation.
	def self::is_supported?
		return self.features.include?( self.validated_parser_type )
	end


	### Check to be sure the parser type is supported before instantiating it
	def self::new( *args )
		raise Redleaf::FeatureError, "unsupported parser type %p" % [ self.parser_type ] unless
		 	self.is_supported?
		super
	end


	# Default to the 'guess' parser
	parser_type :guess


end # class Redleaf::Parser

# vim: set nosta noet ts=4 sw=4:

