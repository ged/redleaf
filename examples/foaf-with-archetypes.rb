#!/usr/bin/env ruby

# Port of the example from foaf1.rb using Redleaf Archetypes

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).expand_path.dirname.parent
	libdir = basedir + 'lib'
	extdir = basedir + 'ext'
	
	$LOAD_PATH.unshift( libdir.to_s ) unless $LOAD_PATH.include?( libdir.to_s )
	$LOAD_PATH.unshift( extdir.to_s ) unless $LOAD_PATH.include?( extdir.to_s )
}

require 'redleaf'
require 'redleaf/archetypes'
require 'logger'

Redleaf.logger.level = Logger::DEBUG

FOAF = Redleaf::Namespace.new( "http://xmlns.com/foaf/0.1/" )

class Person
	include Redleaf::Archetypes
	include_archetype FOAF[:Person]
end

graph = Redleaf::Graph.new
graph.load( "http://bigasterisk.com/foaf.rdf" )
graph.load( "http://www.w3.org/People/Berners-Lee/card.rdf" )
graph.load( "http://danbri.livejournal.com/data/foaf" ) 

people = Person.find_in( graph )

# Use the most-consanguine 'knows' property:
people.each do |person|
	person.knows.each do |other_person|
		puts "%s knows %s" % [ person.name, other_person.name ]
	end
end

# Explicitly use the FOAF[:knows] predicate
people.each do |person|
	person[ FOAF[:knows] ].each do |other_person|
		puts "%s knows %s" % [ person.name, other_person.name ]
	end
end

# Output:
#   Timothy Berners-Lee knows Edd Dumbill
#   Timothy Berners-Lee knows Jennifer Golbeck
#   Timothy Berners-Lee knows Nicholas Gibbins
#   Timothy Berners-Lee knows Nigel Shadbolt
#   Dan Brickley knows binzac
#   Timothy Berners-Lee knows Eric Miller
#   Drew Perttula knows David McClosky
#   Timothy Berners-Lee knows Dan Connolly
#   ...
