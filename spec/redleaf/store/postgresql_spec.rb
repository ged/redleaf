#!/usr/bin/env ruby

BEGIN {
	require 'rbconfig'
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent.parent

	libdir = basedir + "lib"
	extdir = libdir + Config::CONFIG['sitearch']

	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

begin
	require 'spec'
	require 'spec/lib/constants'
	require 'spec/lib/helpers'
	require 'spec/lib/store_behavior'

	require 'redleaf'
	require 'redleaf/store/postgresql'
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

describe Redleaf::PostgreSQLStore do
	include Redleaf::SpecHelpers

	before( :all ) do
		setup_logging( :fatal )
		@store_config = get_test_config( 'postgresql' )
	end


	before( :each ) do
		pending "no postgresql backend; will not test" unless Redleaf::PostgreSQLStore.is_supported?
	end


	after( :all ) do
		reset_logging()
	end


	it "can be created with a name" do
		store = safely_create_store( Redleaf::PostgreSQLStore, TESTING_STORE_NAME, @store_config )
		store.should be_an_instance_of( Redleaf::PostgreSQLStore )
	end


	describe "instance" do

		before( :each ) do
			@store = safely_create_store( Redleaf::PostgreSQLStore, TESTING_STORE_NAME, @store_config )
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


			it "has contexts enabled by default" do
				@store.should have_contexts()
			end

		end
	end

end

# vim: set nosta noet ts=4 sw=4:
