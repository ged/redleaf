#!/usr/bin/env ruby

# A port of the 'skosdex' library by Dan Brickley <danbri@danbri.org> from 
#   http://svn.foaf-project.org/foaftown/2009/skosdex/src/jena_skos.rb

BEGIN {
	require 'pathname'
	basedir = Pathname( __FILE__ ).dirname.parent
	libdir = basedir + 'lib'
	extdir = basedir + 'ext'
	
	$LOAD_PATH.unshift( libdir, extdir )
}

require 'redleaf'
require 'redleaf/constants'
require 'logger'


module SKOS
	NS = Redleaf::Namespace.new( "http://www.w3.org/2004/02/skos/core#" )

	DEFAULT_SOURCE = "file:data.rdf"

	class ConceptScheme
		include Redleaf::Loggable,
		        Redleaf::Constants::CommonNamespaces

		### Create a new SKOS::ConceptScheme from the 
		def initialize( *sources )
			super()

			@concepts = {}
			@needs_indexing = false
			@store = Redleaf::HashesStore.load( 'skos', :new => true )
			@graph = @store.graph
			self.log.debug "Graph has %d triples" % [ @graph.size ]
			
			self.load( *sources )
		end


		######
		public
		######

		# The Hash of Concepts read from the graph, keyed by subject
		attr_reader :concepts
		
		# The Redleaf::Model that contains the ConceptScheme's Concepts
		attr_reader :graph
		
		# Whether or not the ConceptScheme needs to (re)generate Concepts from the
		# triples in its graph
		attr_reader :needs_indexing
		alias_method :needs_indexing?, :needs_indexing


		### Look up the Concept that corresponds to the given +uri+ and return it. Returns
		### +nil+ if the Concept is not contained in the ConceptSchema's graph.
		def []( uri )
			self.index_concepts if self.needs_indexing?
			uri = URI( uri )
			return @concepts[ uri ]
		end
		

		### Read the ConceptScheme's RDF triples from the given +source+, which can be anything
		### supported by Redleaf::Graph#load.
		def load( *sources )
			sources.each do |source|
				self.log.debug "Reading triples from %p" % [ source ]
				@graph.load( source )
				@graph.sync
			end

			@needs_indexing = true
			self.log.debug "  done."
		end


		### Find other Concepts which are related to the given +concept+ via the +relationship+ 
		### specified and yield them to the provided block.
		def related_concepts( concept, relationship ) # :yield: concept
			self.index_concepts if self.needs_indexing?
			results = []
			
			self.log.debug "Finding concepts which are %s than %s" % [ relationship, concept ]
			rel_concepts = @graph.objects( concept.uri, SKOS::NS[relationship] ).
				collect {|uri| @concepts[uri] }
			known_rel_concepts = rel_concepts.compact

			self.log.debug "Found %d %s concepts, %d of which are in the current scheme." %
				[ rel_concepts.length, relationship, known_rel_concepts.length ]
			
			known_rel_concepts.each do |rel_concept|
				results << rel_concept
				yield( rel_concept ) if block_given?
			end
			
			return results
		end


		#########
		protected
		#########

		### Create SKOS::Concepts from any Concept triples in the current #graph that don't 
		### already have one and append them to #concepts.
		def index_concepts
			self.log.debug "Loading Concepts from %p" % [ @graph ]
			concept_uris = @graph.subjects( RDF[:type], SKOS::NS[:Concept] )
			self.log.debug "  found %d concepts" % [ concept_uris.length ]
			beforecount = @concepts.length

			concept_uris.each do |subj|
				# self.log.debug "  loading %p" % [ subj ]
				label = @graph.object( subj, SKOS::NS[:prefLabel] )
				@concepts[ subj ] ||= SKOS::Concept.new( self, subj, label )
			end
			
			self.log.debug "  loaded %d new concepts" % [ @concepts.length - beforecount ]
			@needs_indexing = false
		end
		
		
	end # class ConceptScheme


	### The Concept class
	class Concept
		include Redleaf::Loggable

		### Create a new SKOS::Concept from the specified +scheme+ that corresponds to the given 
		### +uri.
		def initialize( scheme, uri, prefLabel="" )
			super()
			
			@scheme    = scheme
			@uri       = uri
			@prefLabel = prefLabel
		end 


		######
		public
		######

		# The value of the 'prefLabel' property
		attr_reader :prefLabel
		
		# The URI of the Concept
		attr_reader :uri
		
		# The SKOS::ConceptScheme this Concept belongs to
		attr_reader :scheme


		### Return the Concept as a String using its URI and prefLabel
		def to_s
			return "%s %s" % [ self.uri, self.prefLabel ]
		end
		

		### Find Concepts that are 'narrower' than the receiver and return them. If a block
		### is given, each Concept will be yielded to it as it is found.
		def narrower( &block )
			return @scheme.related_concepts( self, :narrower, &block )
		end

		### Find Concepts that are 'broader' than the receiver and return them. If a block
		### is given, each Concept will be yielded to it as it is found.
		def broader( &block )
			return @scheme.related_concepts( self, :broader, &block )
		end

	end
end


# You can grab the RDF/XML file from:
#   http://www.ukat.org.uk/downloads/skos.zip


if __FILE__ == $0
	Redleaf.logger.level = Logger::DEBUG
	test_concept = "http://www.ukat.org.uk/thesaurus/concept/1366"

	sources = [
		"http://norman.walsh.name/knows/taxonomy",
		"http://www.wasab.dk/morten/blog/archives/author/mortenf/skos.rdf",
		"file:skos_ukatdata_20040822.xml",
		#"file:samples/archives.rdf", # this isn't in svn, so I'm not sure what it contains
	]

	scheme = SKOS::ConceptScheme.new( *sources )

	# scheme.read_from_source(  )
	# $stderr.puts "Scheme concepts are: %p" % [ scheme.concepts ]
	
	agronomy = scheme[ test_concept ] or
		raise "Couldn't find test concept %p" % [ test_concept ]
	puts "test concept is %s" % [ agronomy ]

	agronomy.narrower do |concept|
		puts "  narrower: %s" % [ concept ]
		concept.narrower do |subconcept|
			puts "    narrower: %s" % [ subconcept ]
		end
	end

end

