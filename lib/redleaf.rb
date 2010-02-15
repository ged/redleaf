#!/usr/bin/env ruby

require 'logger' 


# An RDF library for Ruby. See the README for more details.
#
# == Starting Points
# 
# [Redleaf::Graph]
#   The main RDF container class.
# [Redleaf::Statement]
#   The RDF "triple" class -- graphs contain zero or more of these.
# [Redleaf::QueryResult]
#   Call Redleaf::Graph#query with a valid SPARQL query returns one of these. 
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
module Redleaf

	# Library version
	VERSION = '0.0.1'

	# Version control revision
	REVISION = %q$Revision$


	# Load the logformatters and some other stuff first
	require 'redleaf/utils'

	### Logging 
	@default_logger = Logger.new( $stderr )
	@default_logger.level = $DEBUG ? Logger::DEBUG : Logger::WARN

	@default_log_formatter = Redleaf::LogFormatter.new( @default_logger )
	@default_logger.formatter = @default_log_formatter

	@logger = @default_logger


	class << self
		# The log formatter that will be used when the logging subsystem is reset
		attr_accessor :default_log_formatter

		# The logger that will be used when the logging subsystem is reset
		attr_accessor :default_logger

		# The logger that's currently in effect
		attr_accessor :logger
		alias_method :log, :logger
		alias_method :log=, :logger=
	end


	### Reset the global logger object to the default
	def self::reset_logger
		self.logger = self.default_logger
		self.logger.level = Logger::WARN
		self.logger.formatter = self.default_log_formatter
	end


	### Returns +true+ if the global logger has not been set to something other than
	### the default one.
	def self::using_default_logger?
		return self.logger == self.default_logger
	end


	### Return the library's version string
	def self::version_string( include_buildnum=false )
		vstring = "%s %s" % [ self.name, VERSION ]
		vstring << " (build %s)" % [ REVISION[/.*: ([[:xdigit:]]+)/, 1] || '0' ] if include_buildnum
		return vstring
	end

	require 'redleaf_ext'

	require 'redleaf/exceptions'
	require 'redleaf/graph'
	require 'redleaf/mixins'
	require 'redleaf/namespace'
	require 'redleaf/parser'
	require 'redleaf/store'
	require 'redleaf/core_extensions'

	### Create and return a Redleaf::Namespace for the specified +uristring+.
	def self::Namespace( uristring )
		Redleaf::Namespace.new( uristring )
	end

end # module Redleaf


