#!/usr/bin/env ruby

require 'uri'
require 'pp'
require 'tsort'

require 'redleaf'
require 'redleaf/mixins'

# An RDF graph class
# 
# == Version-Control Id
#
#  $Id$
# 
# == Authors
# 
# Portions of this file (namely the graph-equivalence stuff) were ported to Ruby from 
# the Test::RDF Perl module written by Michael Hendricks. His copyright is:
# 
#   Copyright (C) 2006 Michael Hendricks <michael@palmcluster.org>
#   
#   This program is free software; you can redistribute it and/or modify it
#   under the same terms as Perl itself.
#   
# * Michael Granger <ged@FaerieMUD.org>
# 
# :include: LICENSE
#
#--
#
# Please see the file LICENSE in the BASE directory for licensing details.
#
class Redleaf::Graph
	include Redleaf::Loggable,
	        Enumerable


	### A convenience class for keeping track of node mappings between two graphs while
	### testing for equivalence.
	### The ideas in this class were modelled after concepts in Michael Hendricks's Test::RDF 
	### Perl module.
	class BnodeMap # :nodoc:

		### Create a new Bnode map
		def initialize
			@a_to_b = {}
			@b_to_a = {}
		end

		### Look up a mapping for the specified +node+
		def []( node )
			return @a_to_b[ node ]
		end

		### Returns +true+ if there isn't already a mapping in either direction for
		### the two nodes specified.
		def valid?( node_a, node_b )
			return false if @a_to_b.key?( node_a ) ||
			                @b_to_a.key?( node_b )
        	return true
		end

        ### Create a new mapping for the specified nodes.
		def create( node_a, node_b )
			raise "invalid mapping" unless self.valid?( node_a, node_b )
			@a_to_b[ node_a ] = node_b
			@b_to_a[ node_b ] = node_a
		end
		alias_method :[]=, :create

	end # class BnodeMap


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Returns +true+ if the specified +format+ is supported by the Redland backend.
	def self::valid_format?( format )
		Redleaf.logger.debug "Checking validity of format %p" % [ format ]
		return self.serializers.key?( format )
	end


	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	######
	public
	######

	### Returns +true+ if the graph does not contain any statements.
	def empty?
		return self.size.zero?
	end
	alias_method :is_empty?, :empty?


	# Append objects to the graph, either as Redleaf::Statements, valid
	# triples in Arrays, or a subgraph of nodes expressed in a Hash.
	# 
	#   require 'redleaf/constants'
	#   incude Redleaf::Constants::CommonNamespaces # (for the FOAF namespace constant)
	#   
	#   MY_FOAF = Redleaf::Namspace.new( 'http://deveiate.org/foaf.xml#' )
	#   michael = MY_FOAF[:me]
	#   
	#   graph = Redleaf::Graph.new
	#   
	#   statement1 = Redleaf::Statement.new( michael, FOAF[:family_name], 'Granger' )
	#   statement2 = [ michael, FOAF[:givenname], 'Michael' ]
	#   graph.append( statement1, statement2 )
	#   
	#   graph << [ michael, FOAF[:homepage], URI('http://deveiate.org/') ]
	# 
	#   graph << {
	#     michael => {
	#       RDF[:type] => FOAF[:Person],
	#       FOAF[:knows] => {
	#         RDF[:type] => FOAF[:Person],
	#         FOAF[:givenname] => "Mahlon",
	#         FOAF[:family_name] => "Smith",
	#       }
	#     }
	def append( *objects )
		statements = objects.collect do |obj|
			Redleaf.log.debug "Appending object %p" % [ obj ]
			stmt = obj.is_a?( Redleaf::Statement ) ? obj : Redleaf::Statement.create( obj )
			Redleaf.log.debug "  object statement: %p" % [ stmt ]
			stmt
		end.flatten

		return self.append_statements( *statements )
	end
	alias_method :<<, :append


	### Run a SPARQL +query+ against the graph. The optional +prefixes+ hash can be
	### used to set up prefixes in the query.
	###
	###    require 'redleaf/constants'
	###    include Redleaf::Constants::CommonNamespaces
	###    
	###    # Declare a custom namespace and create a graph with a node about its title
	###    book = Redleaf::Namespace.new( 'http://example.org/book' )
	###    graph = Redleaf::Graph.new
	###    graph << [ book[:book1], DC[:title], "SPARQL Tutorial" ]
	###    
	###    qstring = 'SELECT ?title WHERE { book:book1 dc:title ?title }'
	###    res = graph.query( qstring, :book => book, :dc => DC )
	###    # => #<Redleaf::BindingsQueryResult:0x07466b3>
	###    
	###    res.each do |row|
	###    		puts row.title
	###    end
	###
	def query( querystring, *args )
		qnames = args.last.is_a?( Hash ) ? args.last : {}
		self.log.debug "Qnames hash is: %p" % [ qnames ]

		prelude = qnames.collect {|prefix, uri| "PREFIX %s: <%s>\n" % [ prefix, uri ] }.join
		querystring = prelude + querystring
		self.log.debug "Querystring is: %p" % [ querystring ]

		return self.execute_query( querystring )
	end


	### call-seq:
	###    graph.is_equivalent_to?( other_graph )   -> true or false
	###    graph === other_graph                    -> true or false
	### 
	### Equivalence method -- compare the receiving +graph+ with +other_graph+ according to
	### the graph equivalency rules in:
	###   http://www.w3.org/TR/rdf-concepts/#section-graph-equality
	def is_equivalent_to?( other_graph )
		unless other_graph.size == self.size
			self.log.debug "Graphs differ in size (%d vs. %d)" % [ self.size, other_graph.size ]
			return false
		end

		other = other_graph.dup
		bnode_map = BnodeMap.new
		difference = nil

		difference = self.find do |stmt|
			# If the copy of the other graph has an equivalent statement, remove it
			# and move on to the next one.
			if other.remove_equivalent_statement( stmt, bnode_map )
				next

			# Otherwise, we've found a difference
			else
				stmt
			end
		end

		buf = ''
		PP.pp( bnode_map, buf )
		self.log.debug "Bnode map after comparison:\n%s" % [ buf ]

		if difference
			self.log.debug "%p is not equivalent to %p because it does not contain %p" %
				[ self, other_graph, difference ]
			return false
		else
			return true
		end
	end
	alias_method :equivalent_to?, :is_equivalent_to?
	alias_method :===, :is_equivalent_to?


	### Return a human-readable representation of the object suitable for debugging.
	def inspect
		return "#<%s:0x%x %d statements, %s>" % [
			self.class.name,
			self.object_id * 2,
			self.size,
			self.context_info
		]
	end


	### Return a string describing the status of contexts in the receiving graph. This will be a
	### count of the contexts if they are enabled, or "contexts not enabled" if they aren't enabled.
	def context_info
		if self.contexts_enabled?
			return "%d contexts" % [ self.contexts.length ]
		else
			return "contexts disabled"
		end
	end


	### Defined explicitly so the 'json' library's default implementation doesn't override
	### the serializer.
	def to_json( qnames={} )
		return self.serialized_as( 'json', qnames )
	end


	### Return the graph as RDF/XML.
	def to_xml( qnames={} )
		return self.to_rdfxml( qnames )
	end



	#########
	protected
	#########

	### Proxy method -- handle #to_«format» methods by invoking a serializer for the
	### specified +format+.
	def method_missing( sym, *args )
		super unless sym.to_s =~ /^to_(\w+)$/

		format = $1.tr( '_', '-' )
		super unless self.class.valid_format?( format )

		serializer = lambda {|*qnames| self.serialized_as(format, *qnames) }

		# Install the closure as a new method and call it
		self.class.send( :define_method, sym, &serializer )
		return self.method( sym ).call( *args )
	end


	### Given the specified +bnode_map+ (a BnodeMap object which contains an equivalence 
	### mapping between blank nodes in the receiver and +statement+), remove the given 
	### +statement+ from the receiver if an equivalent one exists. If an equivalent exists, 
	### return it, otherwise return +nil+. This was ported from Michael Hendricks's 
	### Test::RDF Perl module.
	### :TODO: Refactor into multiple methods
	def remove_equivalent_statement( statement, bnode_map )
		subject	  = statement.subject
		predicate = statement.predicate
		object	  = statement.object

		subject_is_floating = false
		object_is_floating  = false

		# anchor the subject if possible
		if subject.is_a?( Symbol )
			subject_is_floating = true
			if mapped = bnode_map[ subject ]
				subject = mapped
				subject_is_floating = false
			end
		end

		# anchor the object if possible
		if object.is_a?( Symbol )
			object_is_floating = true
			if mapped = bnode_map[ object ]
				object = mapped
				object_is_floating = false
			end
		end

		# If both the subject and object are unmapped bnodes, select the first
		# triple with the same predicate and unmapped bnode subject and objects
		if subject_is_floating && object_is_floating
			self.log.debug "Anchoring a subject (%p) and an object (%p)" %
				[ subject, object ]
			equivalent = self[ nil, predicate, nil ].find do |stmt|
				self.log.debug "  examining %p" % [ stmt ]
				if stmt.subject.is_a?( Symbol ) &&
				   stmt.object.is_a?( Symbol ) &&
				   bnode_map.valid?( subject, stmt.subject ) &&
				   bnode_map.valid?( object, stmt.object )

					bnode_map[ subject ] = stmt.subject
					bnode_map[ object ] = stmt.object

					stmt
				end
			end

		# If the subject is an unanchored bnode, select the first
		# triple with the same predicate and object and an unmapped subject
		elsif subject_is_floating
			self.log.debug "Anchoring a subject (%p)" % [ subject ]
			equivalent = self[ nil, predicate, object ].find do |stmt|
				self.log.debug "  examining %p" % [ stmt ]
				if stmt.subject.is_a?( Symbol ) &&
				   bnode_map.valid?( subject, stmt.subject )

					bnode_map[ subject ] = stmt.subject
					stmt
				end
			end

		# Do the same for an unanchored object
		elsif object_is_floating
			self.log.debug "Anchoring an object (%p)" % [ object ]
			equivalent = self[ subject, predicate, nil ].find do |stmt|
				self.log.debug "  examining %p" % [ stmt ]
				if stmt.object.is_a?( Symbol ) &&
				   bnode_map.valid?( object, stmt.object )

					bnode_map[ object ] = stmt.object
					stmt
				end
			end

		# If the statement's nodes are all either mapped or not bnodes, just
		# search for an equivalent
		else
			self.log.debug "Searching for an anchored statement {%p, %p, %p}" %
				[ subject, predicate, object ]
			equivalent = self[ subject, predicate, object ].first
		end

		self.log.debug "Equivalent is: %p" % [ equivalent ]

		return self.remove( equivalent ).first if equivalent
		return nil
	end


end # class Redleaf::Graph


#--
# Provide an alias for people that *really* want it to be called 'Model'.
module Redleaf # :nodoc:
	Model = Graph
end


# vim: set nosta noet ts=4 sw=4:

