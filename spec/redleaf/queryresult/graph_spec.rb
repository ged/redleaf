#!/usr/bin/env ruby

BEGIN {
	require 'rbconfig'
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent.parent

	libdir = basedir + "lib"
	extdir = libdir + Config::CONFIG['sitearch']

	$LOAD_PATH.unshift( basedir ) unless $LOAD_PATH.include?( basedir )
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

require 'rspec'

require 'spec/lib/helpers'

require 'redleaf'
require 'redleaf/queryresult/graph'
require 'redleaf/behavior/queryresult'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Redleaf::GraphQueryResult do

	CONSTRUCT_SPARQL_QUERY = %{
		PREFIX foaf:    <http://xmlns.com/foaf/0.1/>
		PREFIX vcard:   <http://www.w3.org/2001/vcard-rdf/3.0#>
		CONSTRUCT   { <http://example.org/person#Alice> vcard:FN ?name }
		WHERE       { ?x foaf:name ?name }
	}


	before( :each ) do
		setup_logging( :fatal )
		@graph = Redleaf::Graph.new
		@graph <<
			[ :_a, FOAF[:name], "Alice" ] <<
			[ :_a, FOAF[:mbox], URI('mailto:alice@example.org') ]

		@result = @graph.query( CONSTRUCT_SPARQL_QUERY )
	end

	it_should_behave_like "a Redleaf::QueryResult"


	it "is a graph query result" do
		@result.should be_an_instance_of( Redleaf::GraphQueryResult )
	end

	it "can return a graph" do
		vcard = Redleaf::Namespace.new( 'http://www.w3.org/2001/vcard-rdf/3.0#' )
		@result.graph.should be_an_instance_of( Redleaf::Graph )
		@result.graph.statements.should have(1).member
		@result.graph.statements.first.should == 
			Redleaf::Statement.new( URI('http://example.org/person#Alice'), vcard[:FN], "Alice" )
	end

end

# vim: set nosta noet ts=4 sw=4:
