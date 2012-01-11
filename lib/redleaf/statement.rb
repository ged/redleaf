#!/usr/bin/env ruby

require 'redleaf' 
require 'redleaf/mixins'
require 'redleaf/utils'


# An RDF statement class. A statement is a node-arc-node triple (subject
# --predicate--> object). The subject can be either a URI or a blank node, the
# predicate is always a URI, and the object can be a URI, a blank node, or a
# literal.
#	
# == Subversion Id
#
#	$Id$
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
class Redleaf::Statement
	include Comparable,
	        Redleaf::Loggable,
	        Redleaf::Constants::CommonNamespaces,
	        Redleaf::NodeUtils


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Factory constructor -- create one or more Redleaf::Statement
	### objects from the given +object+ and return them as an Array.
	def self::create( object )
		case object
		when Redleaf::Statement
			return [ object ]

		when Array
			return self.create_from_array( object )

		when Hash
			return self.create_from_hash( object )

		else
			raise ArgumentError, "don't know how to convert a %s to a %s" %
				[ object.class.name, self.name ]
		end
	end


	### Transform an array of objects into an Array of one or more Redleaf::Statements.
	def self::create_from_array( array )

		# Handle the shortcut constructor: [ <subject>, <predicate>, <object> ]
		if array.length == 3 && !( array.first.is_a?(Array) || array.first.is_a?(Hash) )
			return [ self.new(*array) ]
		end

		return array.collect {|obj| self.create(obj) }.flatten
	end

	# {
	# 	:subj => { :pred => :obj,
	# 	           :pred => [:obj, :obj],
	# 	           :pred => {
	# 					:a => FOAF[:Person],
	# 					FOAF[:name] => 'Damian',
	# 				}
	# 	}}
	# }

	### Transform a Hash into an Array of one or more Redleaf::Statements by interpreting 
	### it as a Turtle-like structure.
	def self::create_from_hash( a_hash )
		statements = []
		a_hash.each do |subject, arcs|
			arcs.each do |predicate, objects|
				case objects
				when Array
					objects.each {|obj| statements << self.new(subject, predicate, obj) }

				when Hash
					stmt = self.new( subject, predicate, :_ )
					statements << stmt
					anonid = stmt.object
					Redleaf.log.debug "Hash join statement: %p" % [ stmt ]

					objects.each do |pred2, obj2|
						Redleaf.log.debug "  adding a sub-statement: %p -> %p" % [ pred2, obj2 ]
						statements << self.new( anonid, pred2, obj2 )
					end

				else
					statements << self.new( subject, predicate, objects )
				end
			end
		end

		Redleaf.log.debug "Returning generated statements: %p" % [ statements ]
		return statements.flatten
	end



	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	### Generates a Fixnum hash value for the statement, made up of the hash of its components.
	def hash
		return [ self.subject, self.predicate, self.object ].hash
	end


	### Comparable interface
	def <=>( other )
		self.log.debug "%p <=> %p" % [ self, other ]
		return 0 unless other
		result = ( self.subject.to_s <=> other.subject.to_s ).nonzero? ||
		       ( self.predicate.to_s <=> other.predicate.to_s ).nonzero? ||
		       ( self.object.to_s <=> other.object.to_s )
		return result
	ensure
		self.log.debug "--> %p" % [ result ]
	end


end # class Redleaf::Statement

# vim: set nosta noet ts=4 sw=4:

