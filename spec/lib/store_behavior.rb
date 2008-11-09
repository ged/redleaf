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
	require 'spec'
	require 'spec/lib/constants'
	require 'spec/lib/helpers'

	require 'redleaf'
	require 'redleaf/store'
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

describe "A Store", :shared => true do
	include Redleaf::SpecHelpers


	it "knows which Redland backend it uses" do
		@store.class.backend.should_not be_nil()
	end
	
	it "knows whether it is persistent or not" do
		result = @store.persistent?
		[ true, false ].should include( result )
	end
	
end


describe "A Store with an associated Graph", :shared => true do
	include Redleaf::SpecHelpers

	it "allows the association of a new Graph" do
		graph = Redleaf::Graph.new
		@store.graph = graph
		@store.graph.should == graph
	end

end

# vim: set nosta noet ts=4 sw=4:
