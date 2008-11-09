#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent.parent
	
	libdir = basedir + "lib"
	extdir = basedir + "ext"
	
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

begin
	require 'spec'
	require 'spec/lib/constants'
	require 'spec/lib/helpers'
	require 'spec/lib/queryresult_behavior'

	require 'redleaf'
	require 'redleaf/queryresult/boolean'
rescue LoadError
	unless Object.const_defined?( :Gem )
		require 'rubygems'
		retry
	end
	raise
end


include Redleaf::TestConstants
include Redleaf::Constants

#####################################################################
###	C O N T E X T S
#####################################################################

describe Redleaf::BooleanQueryResult do
	include Redleaf::SpecHelpers


	ASK_SPARQL_QUERY = %{
		PREFIX foaf:    <http://xmlns.com/foaf/0.1/>
		ASK  { ?x foaf:name  "Alice" }
	}


	before( :each ) do
		setup_logging( :fatal )
		@graph = Redleaf::Graph.new
		@graph <<
			[ :_a, FOAF[:name],       "Alice" ] <<
			[ :_a, FOAF[:homepage],   URI.parse('http://work.example.org/alice/') ] <<
			[ :_b, FOAF[:name],       "Bob" ] <<
			[ :_b, FOAF[:mbox],       URI.parse('mailto:bob@work.example') ]

		@result = @graph.query( ASK_SPARQL_QUERY )
	end


	it_should_behave_like "A QueryResult"


	it "is a boolean query result" do
		@result.should be_an_instance_of( Redleaf::BooleanQueryResult )
	end

	it "can return a true or false value" do
		@result.value.should equal( true )
	end

end

