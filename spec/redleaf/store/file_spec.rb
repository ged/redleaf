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
	require 'spec/lib/store_behavior'

	require 'redleaf'
	require 'redleaf/store/file'
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

describe Redleaf::FileStore do
	include Redleaf::SpecHelpers

	TESTING_STORE_NAME = 'splornk'

	before( :all ) do
		setup_logging( :fatal )
	end


	before( :each ) do
		pending "no file backend; will not test" unless Redleaf::FileStore.is_supported?
	end
	

	after( :all ) do
		reset_logging()
		File.delete( TESTING_STORE_NAME ) if File.exist?( TESTING_STORE_NAME )
	end


	it "can be created with a name" do
		Redleaf::FileStore.new( TESTING_STORE_NAME )
	end


	describe "instance" do
		
		before( :each ) do
			@store = Redleaf::FileStore.new( TESTING_STORE_NAME )
		end
		
		
		it_should_behave_like "A Store"
		

		describe "without an associated Redleaf::Graph" do
			it "raises an error when checked for contexts" do
				lambda {
					@store.has_contexts?
				}.should raise_error( RuntimeError, /associated with a graph/i )
			end
		end

		describe "with an associated Redleaf::Graph" do
		
			before( :each ) do
				@store.graph = Redleaf::Graph.new
			end


			it_should_behave_like "A Store with an associated Graph"
		
		end
	end

end

# vim: set nosta noet ts=4 sw=4:
