#!/usr/bin/env ruby

require 'redleaf'
require 'redleaf/parser'
require 'redleaf/parser/turtle'

Redleaf.logger.level = Logger::DEBUG
baseuri = URI('http://www.example.org/')
a_string = <<EOF
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
@prefix s:   <http://example.org/students/vocab#>.

<http://example.org/courses/6.001> s:students [
        a rdf:Bag;
        rdf:_1 <http://example.org/students/Amy>;
        rdf:_2 <http://example.org/students/Mohamed>;
        rdf:_3 <http://example.org/students/Johann>;
        rdf:_4 <http://example.org/students/Maria>;
        rdf:_5 <http://example.org/students/Phuong>
    ].
EOF

Redleaf.logger.level = Logger::DEBUG
parser = Redleaf::TurtleParser.new
graph = parser.parse( a_string, baseuri )
pp graph
pp graph.statements

