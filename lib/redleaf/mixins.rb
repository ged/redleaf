#!/usr/bin/ruby

require 'rbconfig'
require 'erb'
require 'etc'
require 'logger'

require 'redleaf'


# 
# A collection of mixins shared between Redleaf classes. Stolen mostly from ThingFish.
#
module Redleaf # :nodoc:

	# 
	# Add logging to a Redleaf class. Including classes get #log and #log_debug methods.
	# 
	# == Version
	#
	#  $Id$
	#
	# == Authors
	#
	# * Michael Granger <mgranger@laika.com>
	# * Mahlon E. Smith <mahlon@laika.com>
	#
	# :include: LICENSE
	#
	#---
	#
	# Please see the file LICENSE in the 'docs' directory for licensing details.
	#
	module Loggable

		LEVEL = {
			:debug => Logger::DEBUG,
			:info  => Logger::INFO,
			:warn  => Logger::WARN,
			:error => Logger::ERROR,
			:fatal => Logger::FATAL,
		  }

		### A logging proxy class that wraps calls to the logger into calls that include
		### the name of the calling class.
		class ClassNameProxy # :nodoc:

			### Create a new proxy for the given +klass+.
			def initialize( klass, force_debug=false )
				@classname   = klass.name
				@force_debug = force_debug
			end
			
			### Delegate calls the global logger with the class name as the 'progname' 
			### argument.
			def method_missing( sym, msg=nil, &block )
				return super unless LEVEL.key?( sym )
				sym = :debug if @force_debug
				Redleaf.logger.add( LEVEL[sym], msg, @classname, &block )
			end
		end # ClassNameProxy

		#########
		protected
		#########

		### Return the proxied logger.
		def log
			@log_proxy ||= ClassNameProxy.new( self.class )
		end

		### Return a proxied "debug" logger that ignores other level specification.
		def log_debug
			@log_debug_proxy ||= ClassNameProxy.new( self.class, true )
		end
	end # module Loggable

end # module Redleaf

# vim: set nosta noet ts=4 sw=4:

