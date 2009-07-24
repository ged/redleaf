#!/usr/bin/ruby

require 'logger'
require 'erb'
require 'bigdecimal'
require 'date'

require 'redleaf'
require 'redleaf/constants'
require 'redleaf/mixins'


module Redleaf # :nodoc:

	# A collection of node-utility functions
	module NodeUtils
		include Redleaf::Constants::CommonNamespaces

		# Pattern to match ISO8601 durations
		ISO8601_DURATION_PATTERN = %r{
			(-)?							# Optional negative sign ($1)
			P
			(?:(\d+)Y)?						# Years ($2)
			(?:(\d+)M)?						# Months ($3)
			(?:(\d+)D)?						# Days ($4)
			(?:T							# Time separator
				(?:(\d+)H)?					# Hours ($5)
				(?:(\d+)M)?					# Minutes ($6)
				(?:(\d+(?:\.\d+))S)?		# Seconds with optional decimal fraction ($7)
			)?
		}x


		###############
		module_function
		###############

		### Parse the given +string+ containing an ISO8601 duration and return it as
		### a Hash. Returns +nil+ if the string doesn't appear to contain a valid 
		### duration.
		def parse_iso8601_duration( string )
			match = ISO8601_DURATION_PATTERN.match( string ) or
				raise TypeError, "Invalid ISO8601 date %p" % [ string ]

			sign = (match[1] == '-' ? -1 : 1)
			Redleaf.logger.debug "Got sign %p (%p)" % [ match[1], sign ]
			years, months, days, hours, minutes = 
				match.captures[1..-2].collect {|s| s.to_i * sign }
			seconds = match.captures.last.to_f * sign

			return {
				:years   => years,
				:months  => months,
				:days    => days,
				:hours   => hours,
				:minutes => minutes,
				:seconds => seconds,
			}
		end


		# Conversion registry defaults for RDF literal -> Ruby object conversion
		DEFAULT_TYPEURI_REGISTRY = {
			XSD[:string]   => lambda {|str| str },
			XSD[:boolean]  => lambda {|str| str == 'true' },
			XSD[:float]    => lambda {|str| Float(str) },
			XSD[:decimal]  => lambda {|str| BigDecimal(str) },
			XSD[:integer]  => lambda {|str| Integer(str) },
			XSD[:dateTime] => DateTime.method( :parse ),
			XSD[:duration] => Redleaf::NodeUtils.method( :parse_iso8601_duration ),
		}
		DEFAULT_TYPEURI_REGISTRY.freeze
		@@typeuri_registry = DEFAULT_TYPEURI_REGISTRY.dup

		# Conversion registry defaults for Ruby object -> RDF node conversion
		DEFAULT_CLASS_REGISTRY = {
			DateTime => [ XSD[:dateTime], :to_s ],
		}
		DEFAULT_CLASS_REGISTRY.freeze
		@@class_registry = DEFAULT_CLASS_REGISTRY.dup


		### Register a new object that knows how to map strings to Ruby objects for the
		### specified +typeuri+. The +converter+ is any object that responds to #[].
		def register_new_type( typeuri, converter=nil, &block )
			typeuri = URI( typeuri ) unless typeuri.is_a?( URI )
			Redleaf.logger.info "Registering a new object converter for %s literals " % [ typeuri ]

			converter ||= block

			Redleaf.logger.debug "  will convert via %p" % [ converter ]
			@@typeuri_registry[ typeuri ] = converter
		end


		### Register a new class with the type-conversion system. When the _object_ of a
		### Redleaf::Statement is set to an instance of the specified +classobj+, it will
		### be converted to its canonical string form by using the given +converter+ and
		### associated with the specified +typeuri+. The +converter+ should either be an
		### object that responds to #[] or a Symbol that specifies a method on the object
		### that should be called.
		def register_new_class( classobj, typeuri, converter=nil, &block )
			Redleaf.logger.info "Registering a new typed-literal conversion for %p objects." %
			 	[ classobj ]
			typeuri = URI( typeuri ) unless typeuri.is_a?( URI )
			converter ||= block
			converter ||= :to_s

			Redleaf.logger.debug "  will convert to type: %p via %p" % [ typeuri, converter ]
			@@class_registry[ classobj ] = [ typeuri, converter ]
		end


		### Clear the datatype registries of all but the default conversions.
		def clear_custom_types
			@@typeuri_registry.replace( DEFAULT_TYPEURI_REGISTRY )
			@@class_registry.replace( DEFAULT_CLASS_REGISTRY )
		end


		### Convert the specified Ruby +object+ to a typed literal and return it as a tuple of 
		### the form:
		###   [ <canonical_string_value>, <datatype_uri> ]
		def make_object_typed_literal( object )
			Redleaf.logger.debug "Making typed literal from object %p" % [ object ]

			if entry = @@class_registry[ object.class ]
				uri, converter = *entry 
				Redleaf.logger.debug "  literal type URI is: %p" % [ uri ]
				if converter.is_a?( Symbol )
					Redleaf.logger.debug "  converter is %p#%s" % [ object.class, converter ]

					literal = object.__send__(converter)
					Redleaf.logger.debug "  converted to: %p" % [ literal ]
					return [ literal, uri ]
				else
					Redleaf.logger.debug "  converter is %p" % [ converter ]
					literal = converter[object]
					Redleaf.logger.debug "  converted to: %p" % [ literal ]
					return [ literal, uri ]
				end
			else
				raise "no typed-literal conversion for %p objects" % [ object.class ]
			end
		end
		alias_method :object_to_node, :make_object_typed_literal


		### Transform the given +string_value+ into a Ruby object based on the datatype
		### in +typeuri+.
		def make_typed_literal_object( typeuri, string_value )
			unless typeuri.is_a?( URI )
				Redleaf.logger.debug "Converting typeuri %p to a URI object" % [ typeuri ]
				typeuri = URI( typeuri )
			end

			Redleaf.logger.debug "Making Ruby object from typed literal %p<%s>" %
				[ string_value, typeuri ]

			if converter = @@typeuri_registry[ typeuri ]
				Redleaf.logger.debug "  casting function is: %p" % [ converter ]
				return converter[ string_value ]
			else
				Redleaf.logger.error "  I only know about the following typeuris: %p" %
					[ @@typeuri_registry.keys ]
				raise "No object conversion for typed literal %p (%p)" % [ string_value, typeuri ]
			end
		end

	end # module NodeUtils


	# 
	# A alternate formatter for Logger instances.
	# 
	# == Usage
	# 
	#   require 'redleaf/utils'
	#   Redleaf.logger.formatter = Redleaf::LogFormatter.new( Redleaf.logger )
	# 
	# == Version
	#
	#  $Id$
	#
	# == Authors
	#
	# * Michael Granger <mgranger@laika.com>
	#
	# :include: LICENSE
	#
	#--
	#
	# Please see the file LICENSE in the 'docs' directory for licensing details.
	#
	class LogFormatter < Logger::Formatter

		# The format to output unless debugging is turned on
		DEFAULT_FORMAT = "[%1$s.%2$06d %3$d/%4$s] %5$5s -- %7$s\n"

		# The format to output if debugging is turned on
		DEFAULT_DEBUG_FORMAT = "[%1$s.%2$06d %3$d/%4$s] %5$5s {%6$s} -- %7$s\n"


		### Initialize the formatter with a reference to the logger so it can check for log level.
		def initialize( logger, format=DEFAULT_FORMAT, debug=DEFAULT_DEBUG_FORMAT ) # :notnew:
			@logger       = logger
			@format       = format
			@debug_format = debug

			super()
		end

		######
		public
		######

		# The Logger object associated with the formatter
		attr_accessor :logger

		# The logging format string
		attr_accessor :format

		# The logging format string that's used when outputting in debug mode
		attr_accessor :debug_format


		### Log using either the DEBUG_FORMAT if the associated logger is at ::DEBUG level or
		### using FORMAT if it's anything less verbose.
		def call( severity, time, progname, msg )
			args = [
				time.strftime( '%Y-%m-%d %H:%M:%S' ),                         # %1$s
				time.usec,                                                    # %2$d
				Process.pid,                                                  # %3$d
				Thread.current == Thread.main ? 'main' : Thread.object_id,    # %4$s
				severity,                                                     # %5$s
				progname,                                                     # %6$s
				msg                                                           # %7$s
			]

			if @logger.level == Logger::DEBUG
				return self.debug_format % args
			else
				return self.format % args
			end
		end
	end # class LogFormatter


	# 
	# An alternate formatter for Logger instances that outputs +dd+ HTML
	# fragments.
	# 
	# == Usage
	# 
	#   require 'redleaf/utils'
	#   Redleaf.logger.formatter = Redleaf::HtmlLogFormatter.new( Redleaf.logger )
	# 
	# == Version
	#
	#  $Id$
	#
	# == Authors
	#
	# * Michael Granger <mgranger@laika.com>
	#
	# :include: LICENSE
	#
	#--
	#
	# Please see the file LICENSE in the 'docs' directory for licensing details.
	#
	class HtmlLogFormatter < Logger::Formatter
		include ERB::Util  # for html_escape()

		# The default HTML fragment that'll be used as the template for each log message.
		HTML_LOG_FORMAT = %q{
		<div class="log-message %5$s">
			<span class="log-time">%1$s.%2$06d</span>
			[
				<span class="log-pid">%3$d</span>
				/
				<span class="log-tid">%4$s</span>
			]
			<span class="log-level">%5$s</span>
			:
			<span class="log-name">%6$s</span>
			<span class="log-message-text">%7$s</span>
		</div>
		}

		### Override the logging formats with ones that generate HTML fragments
		def initialize( logger, format=HTML_LOG_FORMAT ) # :notnew:
			@logger = logger
			@format = format
			super()
		end


		######
		public
		######

		# The HTML fragment that will be used as a format() string for the log
		attr_accessor :format


		### Return a log message composed out of the arguments formatted using the
		### formatter's format string
		def call( severity, time, progname, msg )
			args = [
				time.strftime( '%Y-%m-%d %H:%M:%S' ),                         # %1$s
				time.usec,                                                    # %2$d
				Process.pid,                                                  # %3$d
				Thread.current == Thread.main ? 'main' : Thread.object_id,    # %4$s
				severity.downcase,                                                     # %5$s
				progname,                                                     # %6$s
				html_escape( msg ).gsub(/\n/, '<br />')                       # %7$s
			]

			return self.format % args
		end

	end # class HtmlLogFormatter

end # module Redleaf

# vim: set nosta noet ts=4 sw=4:

