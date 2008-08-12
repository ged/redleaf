#!/usr/bin/env ruby

require 'redleaf'

# Experiment to work out the set-logic operations of Redleaf's high-level interface.

FOAF = Redleaf::Namespace.new( 'http://xmlns.com/foaf/0.1/' )

graph = Redleaf::Graph.new
graph.parse( "http://bigasterisk.com/foaf.rdf" )
graph.parse( "http://www.w3.org/People/Berners-Lee/card.rdf" )


#
# AND
#

