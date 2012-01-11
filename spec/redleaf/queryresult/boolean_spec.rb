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
require 'redleaf/queryresult/boolean'
require 'redleaf/behavior/queryresult'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Redleaf::BooleanQueryResult do

	ASK_SPARQL_QUERY = %{
		PREFIX foaf:    <http://xmlns.com/foaf/0.1/>
		ASK  { ?x foaf:name  "Alice" }
	}


	before( :each ) do
		setup_logging( :fatal )
		@graph = Redleaf::Graph.new
		@graph <<
			[ :_a, FOAF[:name],       "Alice" ] <<
			[ :_a, FOAF[:homepage],   URI('http://work.example.org/alice/') ] <<
			[ :_b, FOAF[:name],       "Bob" ] <<
			[ :_b, FOAF[:mbox],       URI('mailto:bob@work.example') ]

		@result = @graph.query( ASK_SPARQL_QUERY )
	end


	it_should_behave_like "a Redleaf::QueryResult"


	it "is a boolean query result" do
		@result.should be_an_instance_of( Redleaf::BooleanQueryResult )
	end

	it "can return a true or false value" do
		@result.value.should equal( true )
	end

end

