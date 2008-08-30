#!/usr/bin/env ruby
 
begin
	require 'uri'
	require 'bigdecimal'
	require 'date'
	require 'duration'

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

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Transform the given +string_value+ into a Ruby object based on the datatype
	### in +typeduri+.
	def self::make_typed_literal_object( typeuri, string_value )
	
		case typeuri
		when XSD[:string]
			return string_value
			
		when XSD[:float]
			return Float( string_value )
			
		when XSD[:decimal]
			return BigDecimal( string_value )

		when XSD[:dateTime]
			return DateTime.parse( string_value )

		when XDS[:duration]
			return Duration.new( )

		else
			# Figure out what else to return
		end
	end
	
	### Transform the given +object+ into a tuple of [ canonical_string_value, datatype_uri ]
	### and return it as an Array.
	def self::make_object_typed_literal( object )
		raise NotImplementedError, "Not implemented yet"
	end
	

	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	


	### Equivalence method -- two Redleaf::Statements are equivalent if their subject and object
	### nodes are equivalent according to the bijective function described in:
	###   http://www.w3.org/TR/2004/REC-rdf-concepts-20040210/#section-graph-equality
	### and they have the same predicate.
	def eql?( other_statement )
		
	end
	

end # class Redleaf::Statement

# vim: set nosta noet ts=4 sw=4:

