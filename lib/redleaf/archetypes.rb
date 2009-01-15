#!/usr/bin/ruby

require 'tmpdir'
require 'pathname'
require 'singleton'

require 'redleaf'
require 'redleaf/namespace'
require 'redleaf/exceptions'
require 'redleaf/store/hashes'


# A meta-mixin that adds the ability to describe a class's structure in terms of
# RDF classes.
#
# = Example
# 
#    require 'redleaf/archetypes'
#    require 'redleaf/constants'
#    
#    class Project
#        include Redleaf::Archetypes,
#                Redleaf::Constants::CommonNamespaces
#        include_archetype DOAP[:Project]
#    end
#    
#    class Version
#        include Redleaf::Archetypes,
#                Redleaf::Constants::CommonNamespaces
#        include_archetype DOAP[:Version]
#    end
#    
#    class SVNRepository
#        include Redleaf::Archetypes,
#                Redleaf::Constants::CommonNamespaces
#        include_archetype DOAP[:SVNRepository]
#    end
#    
#    
#    redleaf = Project.new( 'http://deveiate.org/projects/Redleaf' )
#    redleaf.created = Date.new( "2008-11-21" )
#    redleaf.license = URI( 'http://usefulinc.com/doap/licenses/asl20' )
#    redleaf.name = 'Redleaf'
#    redleaf.homepage = URI( 'http://deveiate.org/projects/Redleaf' )
#    redleaf.shortdesc = 'An RDF library for Ruby'
#    redleaf.description = <<-EOF
#        Redleaf is an RDF library for Ruby. It's composed of a hand-written
#        binding for the Redland RDF Library, and a high-level layer that
#        adds some idioms that Rubyists might find familiar.
#    EOF
#    redleaf.bug_database = URI( "http://deveiate.org/projects/Redleaf/report" )
#    redleaf.download_page = URI( "http://deveiate.org/projects/Redleaf/wiki" )
#    redleaf.programming_language = [ 'Ruby', 'C' ]
#    redleaf.category = 'library'
#    
#    version_0_0_1 = Version.new(
#    	:name => 'Maple',
#    	:created => Date.new('2008-12-01'),
#    	:revision => '0.0.1'
#      )
#    redleaf.release = [ version_0_0_1 ]
#    
#    repo = SVNRepository.new(
#    	:location => URI('http://svn://deveiate.org/Redleaf'),
#    	:browse => URI('http://deveiate.org/projects/Redleaf/browser')
#      )
#    redleaf.repository = [ repo ]
#    
#    redleaf.to_rdfxml
# 
module Redleaf::Archetypes
	include Redleaf::Loggable

	
	### The methods to add to including classes
	module ClassMethods

		attr_accessor :archetypes
		
		### Add an Archetype for the RDF Class declared at the specified +uri+ to the
		### receiving Class or Module.
		def include_archetype( uri, options={} )
			uri = URI( uri ) unless uri.is_a?( URI )
			@archetypes ||= {}
			@archetypes[ uri ] = options

			Redleaf.logger.debug "Extending %p with %s" % [ self, uri ]
		end
		
	end # module ClassMethods

	
	### Inclusion callback -- add the ability to declare Archetypes for the including Class or
	### Module.
	def self::included( mod )
		mod.extend( ClassMethods )
	end


	### A factory that can create a mixin on the fly from an RDF Class. It is responsible for
	### discovering the vocabulary the class is from, loading it, and generating a Module object
	### from the Properties in the class's domain.
	class MixinFactory

		# The directory that the registry cache store is created in
		REGISTRY_CACHE_DIR = Pathname.new( Dir.tmpdir )

		### Create a new MixinFactory that will use the specified directory for its cache of
		### loaded triples.
		def initialize
			@cachedb = REGISTRY_CACHE_DIR + 'redleaf' + 'archetypes'
			@cachedb.mkpath

			@modules = {}
			@store = Redland::HashesStore.load( @cachedb )
			@graph = @store.graph
		end
		
		
		######
		public
		######

		### Fetch the archetype module for the given +uri+, fetching the vocabulary and creating
		### the module if necessary.
		def get_archetype_module( classuri )
			@modules[ key ] ||= self.make_module_for( classuri )
			return @modules[ classuri ]
		end


		### Create a new Module object that provides the functionality described by the 
		### given +classuri+.
		def make_module_for( classuri )
			properties = nil
			
		end


		### Return an Array of class property statements for the given +classuri+, loading the 
		### containing vocabulary if it isn't already loaded.
		def get_class_properties( classuri )

			# If the graph doesn't yet have the necessary vocabulary loaded, try to load it
			# ourselves.
			unless @graph.has_subject?( classuri )
				vocabulary, typename = split_typeuri( classuri )

				stmt_count = @graph.load( vocabulary )

				unless @graph.has_subject?( classuri )
					raise Redleaf::Error,
						"Loading the vocabulary at %s didn't add any statements describing %s" %
						[ vocabulary, typename ]
				end
			end

			
		end
		

		#######
		private
		#######

		### Split the given +uri+ into a vocabulary uri and a type name.
		def split_typeuri( uri )
			vocabulary = uri.dup
			typename = nil

			if uri.fragment
				typename = uri.fragment
				vocabulary.fragment = nil
			else
				typename = uri.path.sub( %r{.*/}, '' )
				vocabulary.path = uri.path.sub( %r{/[^/]*$}, '' )
			end

			return vocabulary, typename
		end
		
		
	end # class MixinFactory
	
end # module Redleaf::Archetypes

# vim: set nosta noet ts=4 sw=4:

