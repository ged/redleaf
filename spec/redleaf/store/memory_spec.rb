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
require 'redleaf/store/memory'
require 'redleaf/behavior/store'


#####################################################################
###	C O N T E X T S
#####################################################################
describe Redleaf::MemoryStore do

	before( :all ) do
		setup_logging( :fatal )
	end

	before( :each ) do
		@store = Redleaf::MemoryStore.new
	end

	after( :all ) do
		reset_logging()
	end


	it_should_behave_like "a Redleaf::Store"


	it "can be created with a name" do
		Redleaf::MemoryStore.new( "storename" )
	end

	context "without an associated Redleaf::Graph" do

		it "raises an error when checked for contexts" do
			expect {
				@store.has_contexts?
			}.to raise_error( RuntimeError, /associated with a graph/i )
		end

	end

	context "with an associated Redleaf::Graph" do

		before( :each ) do
			@store.graph = Redleaf::Graph.new
		end

		it "has contexts enabled by default" do
			@store.should have_contexts()
		end

	end

end

# vim: set nosta noet ts=4 sw=4:
