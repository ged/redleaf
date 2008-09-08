#!/usr/bin/env ruby
 
begin
	require 'uri'
	require 'bigdecimal'
	require 'date'

	require 'redleaf'
rescue LoadError => err
	unless Object.const_defined?( :Gem )
		require 'rubygems'
		retry
	end
	raise
end


# An RDF statement class. A statement is a node-arc-node triple (subject --predicate--> object). The
# subject can be either a URI or a blank node, the predicate is always a URI, and the object can
# be a URI, a blank node, or a literal.
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
class Redleaf::Statement
	include Redleaf::Loggable,
	        Redleaf::Constants::CommonNamespaces

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$

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


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Transform the given +string_value+ into a Ruby object based on the datatype
	### in +typeduri+.
	def self::make_typed_literal_object( typeuri, string_value )
		typeuri = URI.parse( typeuri ) unless typeuri.is_a?( URI )
		Redleaf.logger.debug "Making typed literal from %p<%s>" % [ string_value, typeuri ]

		case typeuri
		when XSD[:string]
			return string_value
			
		when XSD[:boolean]
			return string_value == 'true'
			
		when XSD[:float]
			return Float( string_value )
			
		when XSD[:decimal]
			return BigDecimal( string_value )

		when XSD[:integer]
			return Integer( string_value )

		when XSD[:dateTime]
			return DateTime.parse( string_value )

		when XSD[:duration]
			duration = parse_iso8601_duration( string_value ) or
				raise TypeError, "Invalid ISO8601 date %p" % [ string_value ]
			return duration

		else
			raise "Unknown typed literal %p (%p)" % [ string_value, typeuri ]
		end
	end
	
	
	### Parse the given +string+ containing an ISO8601 duration and return it as
	### a Hash. Returns +nil+ if the string doesn't appear to contain a valid 
	### duration.
	def self::parse_iso8601_duration( string )
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
	def self::make_object_typed_literal( object )
		raise NotImplementedError, "Not implemented yet"
	end
	

	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

end # class Redleaf::Statement

# vim: set nosta noet ts=4 sw=4:

