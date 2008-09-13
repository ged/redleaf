#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent
	
	libdir = basedir + "lib"
	extdir = basedir + "ext"
	
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

begin
	require 'spec/runner'
	require 'spec/lib/constants'
	require 'spec/lib/helpers'

	require 'redleaf'
	require 'redleaf/graph'
	require 'redleaf/statement'
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

describe Redleaf::Graph do
	include Redleaf::SpecHelpers


	before( :all ) do
		setup_logging( :fatal )
	end


	after( :all ) do
		reset_logging()
	end


	describe "with no nodes" do
		before( :each ) do
			@graph = Redleaf::Graph.new
		end


		it "is equivalent to another graph with no nodes" do
			other_graph = Redleaf::Graph.new
			@graph.should == other_graph
		end
		
		it "has a default store" do
			@graph.store.should be_an_instance_of( Redleaf::DEFAULT_STORE_CLASS )
		end

		
		
		it "can have statements appended to it as Redleaf::Statements" do
			michael = URI.parse( 'mailto:ged@FaerieMUD.org' )
			mahlon  = URI.parse( 'mailto:mahlon@martini.nu' )
			stmt = Redleaf::Statement.new( michael, FOAF[:knows], mahlon )
			stmt2 = Redleaf::Statement.new( mahlon, FOAF[:knows], michael )
			
			@graph << stmt << stmt2
			
			@graph.statements.should have(2).members
			@graph.statements.should include( stmt, stmt2 )
		end

		it "can have statements appended to it as simple triples" do
			michael = URI.parse( 'mailto:ged@FaerieMUD.org' )
			mahlon  = URI.parse( 'mailto:mahlon@martini.nu' )
			
			stmt = Redleaf::Statement.new( michael, FOAF[:knows], mahlon )
			stmt2 = Redleaf::Statement.new( mahlon, FOAF[:knows], michael )

			@graph <<
				[ michael, FOAF[:knows], mahlon  ] <<
				[ mahlon,  FOAF[:knows], michael ]
			
			@graph.statements.should have(2).members
			@graph.statements.should include( stmt, stmt2 )
		end
		
		
	end
	
end

# vim: set nosta noet ts=4 sw=4:
