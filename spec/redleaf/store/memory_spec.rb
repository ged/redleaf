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
	require 'spec/lib/store_behavior'

	require 'redleaf'
	require 'redleaf/store/memory'
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

describe Redleaf::MemoryStore do
	include Redleaf::SpecHelpers


	before( :all ) do
		setup_logging( :debug )
	end


	after( :all ) do
		reset_logging()
	end


	it "has contexts enabled by defailt" do
		store = Redleaf::MemoryStore.new
		store.should have_contexts()
	end
	
	it "can be created with contexts disabled" do
		store = Redleaf::MemoryStore.new( false )
		store.should_not have_contexts()
	end


	describe "instance" do
		
		before( :each ) do
			@store = Redleaf::MemoryStore.new
		end
		
		
		it_should_behave_like "A Store"
		
	end

end

# vim: set nosta noet ts=4 sw=4:
