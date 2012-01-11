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
require 'redleaf/store/postgresql'
require 'redleaf/behavior/store'


#####################################################################
###	C O N T E X T S
#####################################################################
describe Redleaf::PostgreSQLStore do

	before( :all ) do
		setup_logging( :fatal )
		@store_config = get_test_config( 'postgresql' )
	end

	before( :each ) do
		pending "no postgresql backend; will not test" unless Redleaf::PostgreSQLStore.is_supported?
		@store = safely_create_store( Redleaf::PostgreSQLStore, TESTING_STORE_NAME, @store_config )
	end

	after( :all ) do
		reset_logging()
	end


	it_should_behave_like "a Redleaf::Store"


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
