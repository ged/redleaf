#!/usr/bin/env ruby

# An experiment to determine how Archetypes will work (i.e, 
# http://deveiate.org/projects/Redleaf/wiki/Archetypes)

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).expand_path.dirname.parent
	libdir = basedir + 'lib'
	extdir = basedir + 'ext'

	$LOAD_PATH.unshift( libdir.to_s ) unless $LOAD_PATH.include?( libdir.to_s )
	$LOAD_PATH.unshift( extdir.to_s ) unless $LOAD_PATH.include?( extdir.to_s )
}

require 'redleaf'
require 'redleaf/store/hashes'

# DOAP = Redleaf::Namespace.new( 'http://usefulinc.com/ns/doap#Project' )
# CC = Redleaf::Namespace.new( 'http://web.resource.org/cc/' )
include Redleaf::Constants::CommonNamespaces

$arch_store = Redleaf::HashesStore.load( 'archetypes' )
$arch_graph = $arch_store.graph


# Load the vocabularies if they aren't already
unless $arch_graph.include_subject?( DOAP[:Project] )
	$stderr.puts "Loading DOAP vocabulary."
	$arch_graph.load( DOAP.uri )
else
	$stderr.puts "DOAP vocabulary already loaded."
end

unless $arch_graph.include_subject?( CC[:Work] )
	$stderr.puts "Loading CC vocabulary."
	$arch_graph.load( 'http://web.resource.org/cc/schema.rdf' )
else
	$stderr.puts "CC vocabulary already loaded."
end


def make_module( classuri )
	$stderr.puts "Creating a module for %p" % [ classuri ]

	props = $arch_graph.subjects( RDFS[:domain], classuri ).collect do |property|
		name = property.fragment || property.path.sub( %r{.*/}, '' )
		name.gsub!( /\W+/, '_' )
		$stderr.puts "  adding property %s" % [ name ]

		datatype = $arch_graph.object( property, RDFS[:range] ) || 'Object'
		$stderr.puts "    it's a %p" % [ datatype ]

		'attr_accessor :#{name}'
	end

	mod = Module.new
	mod.module_eval( props.join("\n") )

	return mod
end

DOAP_Project = make_module( DOAP[:Project] )
CC_Work = make_module( CC[:Work] )
CC_License = make_module( CC[:License] )

class Project
	# include Redleaf::Archetypes
	# include_archetype DOAP[:Project]
	# include_archetype CC[:Work]

	include DOAP_Project, CC_Work
end

class License
	# include Redleaf::Architypes
	# include_archetype CC[:License]
	include CC_License

	def initialize( uri )
		self.about = URI.new( uri )
	end
end


apache_license = License.new( 'http://www.apache.org/licenses/LICENSE-2.0' )
bsd_license = License.new( 'http://usefulinc.com/doap/licenses/bsd' )

redland = Project.new
redland.homepage = 'http://librdf.org/'
redland.license = apache_license

redleaf = Project.new
redleaf.homepage = 'http://deveiate.org/projects/Redleaf'
redleaf.license = bsd_license

pp redland
pp redleaf
