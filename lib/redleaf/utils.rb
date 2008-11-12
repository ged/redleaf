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
		
		###############
		module_function
		###############

		### Convert the specified Ruby +object+ to a typed literal and return it as a two-element
		### Array of value and type URI.
		def object_to_node( object )
			Redleaf.log.error "Ack! Can't yet convert %p" % [ object ]
			raise NotImplementedError,
				"node conversions outside of the XML Schema base types is not yet supported."
		end
		

		### Transform the given +string_value+ into a Ruby object based on the datatype
		### in +typeduri+.
		def make_typed_literal_object( typeuri, string_value )
			typeuri = URI.parse( typeuri ) unless typeuri.is_a?( URI )
			Redleaf.logger.debug "Making Ruby object from typed literal %p<%s>" %
				[ string_value, typeuri ]

			case typeuri
			when XSD[:string], XSD_2001[:string]
				return string_value

			when XSD[:boolean], XSD_2001[:boolean]
				return string_value == 'true'

			when XSD[:float], XSD_2001[:float]
				return Float( string_value )

			when XSD[:decimal], XSD_2001[:decimal]
				return BigDecimal( string_value )

			when XSD[:integer], XSD_2001[:integer]
				return Integer( string_value )

			when XSD[:dateTime], XSD_2001[:dateTime]
				return DateTime.parse( string_value )

			when XSD[:duration], XSD_2001[:duration]
				duration = parse_iso8601_duration( string_value ) or
					raise TypeError, "Invalid ISO8601 date %p" % [ string_value ]
				return duration

			else
				raise "Unknown typed literal %p (%p)" % [ string_value, typeuri ]
			end
		end


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


		### Parse the given +string+ containing an ISO8601 duration and return it as
		### a Hash. Returns +nil+ if the string doesn't appear to contain a valid 
		### duration.
		def parse_iso8601_duration( string )
			match = ISO8601_DURATION_PATTERN.match( string ) or return nil

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


		### Transform the given +object+ into a tuple of [ canonical_string_value, datatype_uri ]
		### and return it as an Array.
		def make_object_typed_literal( object )
			raise NotImplementedError, "Not implemented yet"
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
	# * Mahlon E. Smith <mahlon@laika.com>
	#
	# :include: LICENSE
	#
	#---
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
	# * Mahlon E. Smith <mahlon@laika.com>
	#
	# :include: LICENSE
	#
	#---
	#
	# Please see the file LICENSE in the 'docs' directory for licensing details.
	#
	class HtmlLogFormatter < Logger::Formatter
		include ERB::Util  # for html_escape()

		# The default HTML fragment that'll be used as the template for each log message.
		HTML_LOG_FORMAT = %q{
		<dd class="log-message %5$s">
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
		</dd>
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
				severity,                                                     # %5$s
				progname,                                                     # %6$s
				html_escape( msg ).gsub(/\n/, '<br />')                       # %7$s
			]

			return self.format % args
		end
		
	end # class HtmlLogFormatter

end # module Redleaf

# vim: set nosta noet ts=4 sw=4:

