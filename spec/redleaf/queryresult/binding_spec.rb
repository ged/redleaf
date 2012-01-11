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
require 'redleaf/queryresult/binding'
require 'redleaf/behavior/queryresult'


#####################################################################
###	C O N T E X T S
#####################################################################
describe Redleaf::BindingQueryResult do

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


	it_should_behave_like "a Redleaf::QueryResult"



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
