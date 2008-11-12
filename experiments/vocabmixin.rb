#!/usr/bin/env ruby

BEGIN {
	require 'pathname'

	basedir = Pathname.new( __FILE__ ).dirname.parent
	
	extdir = basedir + 'ext'
	libdir = basedir + 'lib'
	
	$LOAD_PATH.unshift( extdir.to_s ) unless $LOAD_PATH.include?( extdir.to_s )
	$LOAD_PATH.unshift( libdir.to_s ) unless $LOAD_PATH.include?( libdir.to_s )
}

require 'pp'
require 'open-uri'

require 'redleaf'
require 'redleaf/constants'
require 'redleaf/graph'
require 'redleaf/store/sqlite'

include Redleaf::Constants::CommonNamespaces

def make_classname( label )
	label.gsub( /(?:\s+|^)(.)/ ) { $1.upcase }
end

store = Redleaf::SQLiteStore.load( 'vocabmixin.db' )
graph = store.graph

if graph.empty?
	$stderr.puts "Loading DOAP vocabulary from #{DOAP}"
	graph.load( DOAP )
else
	$stderr.puts "DOAP vocabulary already loaded."
end


sparql = %{
	SELECT ?klass ?label ?comment ?superclass
	WHERE {
		?klass rdf:type rdfs:Class ;
		       rdfs:label ?label ;
		       rdfs:comment ?comment .
	    OPTIONAL { ?klass rdfs:subClassOf ?superclass . }
		FILTER langMatches( lang(?label), 'EN' ).
		FILTER langMatches( lang(?comment), 'EN' ).
	}
}



classes = {}
graph.query( sparql, :rdf => RDF, :rdfs => RDFS ).each do |row|
	classes[ row[:klass] ] ||= {
		:label => nil,
		:comment => nil,
		:properties => {},
		:superclasses => [],
		:classname => nil,
	}
	classes[ row[:klass] ][ :comment ]      = row[:comment]
	classes[ row[:klass] ][ :label ]        = row[:label]
	classes[ row[:klass] ][ :classname ]    = make_classname( row[:label] )
	classes[ row[:klass] ][ :superclasses ] << row[:superclass]
end


classes.each do |uri,classinfo|
	if classinfo[:superclasses].first.nil?
		$stderr.puts <<-EOF
		class #{ classinfo[:classname] }
		end
		EOF
	elsif local_super = classinfo[:superclasses].find {|uri| classes.key?(uri) }
		$stderr.puts <<-EOF
		class #{ classinfo[:classname] } < #{ classes[local_super][:classname] }
		end
		EOF
	else
		$stderr.puts <<-EOF
		class #{ classinfo[:classname] } < RemoteClass( '#{classinfo[:superclasses].first}' )
		end
		EOF
	end
end




