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

require 'tempfile'
require 'rspec'

require 'spec/lib/helpers'

require 'redleaf'
require 'redleaf/store/file'
require 'redleaf/behavior/store'


#####################################################################
###	C O N T E X T S
#####################################################################
describe Redleaf::FileStore do

	before( :all ) do
		setup_logging( :fatal )
	end

	before( :each ) do
		pending "no file backend; will not test" unless Redleaf::FileStore.is_supported?
		@store = Redleaf::FileStore.new( TESTING_STORE_NAME )
	end

	after( :all ) do
		reset_logging()
		File.delete( TESTING_STORE_NAME ) if File.exist?( TESTING_STORE_NAME )
	end

	it_should_behave_like "a Redleaf::Store"


	it "must be created with a name" do
		expect {
			Redleaf::FileStore.new
		}.to raise_error( ArgumentError, /0 for 1/ )
	end

	context "without an associated Redleaf::Graph" do
		it "raises an error when checked for contexts" do
			expect {
				@store.has_contexts?
			}.to raise_error( RuntimeError, /associated with a graph/i )
		end
	end

end

# vim: set nosta noet ts=4 sw=4:
