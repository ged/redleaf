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
	require 'spec/runner'
	require 'spec/lib/constants'
	require 'spec/lib/helpers'
	require 'spec/lib/queryresult_behavior'

	require 'redleaf'
	require 'redleaf/queryresult/binding'
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

describe Redleaf::BindingQueryResult do
	include Redleaf::SpecHelpers

	SELECT_SPARQL_QUERY = %{
		SELECT ?s ?p ?o
		WHERE
		{
			?s ?p ?o
		}
	}
	

	before( :each ) do
		setup_logging( :fatal )
		@graph = Redleaf::Graph.new
		@graph.append( *TEST_FOAF_TRIPLES )

		@result = @graph.query( SELECT_SPARQL_QUERY )
	end


	it_should_behave_like "A QueryResult"



	it "knows which graph it's from" do
		@result.source_graph.should == @graph
	end

	it "knows how many result rows it contains" do
		@result.length.should == 12
	end

	it "can iterate over its rows" do
		@result.rows.should have(12).members
		
		@result.rows.each do |row|
			row.keys.should include( :s, :p, :o )
		end
	end

end
