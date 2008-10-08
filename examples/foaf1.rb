#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).expand_path.dirname.parent
	libdir = basedir + 'lib'
	extdir = basedir + 'ext'
	
	$LOAD_PATH.unshift( libdir.to_s ) unless $LOAD_PATH.include?( libdir.to_s )
	$LOAD_PATH.unshift( extdir.to_s ) unless $LOAD_PATH.include?( extdir.to_s )
}

require 'redleaf'
require 'logger'

Redleaf.logger.level = Logger::DEBUG

FOAF = Redleaf::Namespace.new( "http://xmlns.com/foaf/0.1/" )

graph = Redleaf::Graph.new
graph.parse( "http://bigasterisk.com/foaf.rdf" )
graph.parse( "http://www.w3.org/People/Berners-Lee/card.rdf" )
graph.parse( "http://danbri.livejournal.com/data/foaf" ) 

# Create foaf:name triples for each foaf:member_name (the attribute LiveJournal uses for the
# member's full name)
graph[ nil, FOAF[:member_name], nil ].each do |stmt|
	graph << [ stmt.subject, FOAF[:name], stmt.object ]
end

sparql = %(
  SELECT ?aname ?bname
  WHERE {
        ?a foaf:knows ?b .
        ?a foaf:name ?aname .
        ?b foaf:name ?bname .
  }
)

graph.query( sparql, :foaf => FOAF ) do |row|
	puts "%s knows %s" % row
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
