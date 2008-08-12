#!/usr/bin/env ruby

require 'redleaf'

# Experiment to work out the set-logic operations of Redleaf's high-level interface.

FOAF = Redleaf::Namespace.new( 'http://xmlns.com/foaf/0.1/' )

model = Redleaf::Model.new
model.parse( "http://bigasterisk.com/foaf.rdf" )
model.parse( "http://www.w3.org/People/Berners-Lee/card.rdf" )


#
# AND
#

# Stuff about Tim Berners-Lee
model[ tbl, nil, nil ]