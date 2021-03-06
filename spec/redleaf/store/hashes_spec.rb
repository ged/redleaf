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
require 'redleaf/store/hashes'
require 'redleaf/behavior/store'


#####################################################################
###	C O N T E X T S
#####################################################################
describe Redleaf::HashesStore do

	before( :all ) do
		setup_logging( :fatal )
	end

	before( :each ) do
		pending "no sqlite backend; will not test" unless Redleaf::HashesStore.is_supported?
	end

	after( :all ) do
		reset_logging()
	end

	it_should_behave_like "a Redleaf::Store"

	# nil and an options hash that specifies nothing  (memory)
	it "normalizes options without any arguments" do
		name, nopts = Redleaf::HashesStore.normalize_options( nil, {} )
		nopts.should == { :hash_type => :memory }
		name.should be_nil
	end

	# nil and an options hash that specifies memory  (memory)
	it "normalizes options with a specified memory type" do
		opts = { :hash_type => :memory }
		name, nopts = Redleaf::HashesStore.normalize_options( nil, opts )
		nopts.should == { :hash_type => :memory }
		name.should be_nil
	end

	# name and an options hash that specifies memory (memory)
	it "normalizes options with a name and a specified memory type" do
		opts = { :hash_type => :memory }
		name, nopts = Redleaf::HashesStore.normalize_options( 'thinfist', opts )
		nopts.should == { :hash_type => :memory }
		name.should == 'thinfist'
	end

	# nil and options hash that says bdb (error)
	it "throws an exception when bdb type is specified and no name is given" do
		opts = { :hash_type => :bdb }
		expect {
			Redleaf::HashesStore.normalize_options( nil, opts )
		}.to raise_error( Redleaf::Error, /you must specify a name argument for the bdb/i )
	end

	# name, {} -> basename(name), {:hash_type => :bdb, :dir => dirname(name)}
	it "normalizes options with a name and no additional options" do
		name, nopts = Redleaf::HashesStore.normalize_options( 'thinfist', {} )
		nopts.should == { :hash_type => :bdb, :dir => '.' }
		name.should == 'thinfist'
	end

	# name, {} -> basename(name), {:hash_type => :bdb, :dir => dirname(name)}
	it "normalizes options with an absolute name and no additional options" do
		name, nopts = Redleaf::HashesStore.normalize_options( '/tmp/thinfist', {} )
		nopts.should == { :hash_type => :bdb, :dir => '/tmp' }
		name.should == 'thinfist'
	end

	# name, { :dir => string } -> name, {:hash_type => :bdb, :dir => string}
	it "normalizes options with a name and a specified directory" do
		opts = { :dir => '/tmp' }
		name, nopts = Redleaf::HashesStore.normalize_options( 'thinfist', opts )
		nopts.should == { :hash_type => :bdb, :dir => '/tmp' }
		name.should == 'thinfist'
	end

	# absolute_name, { :dir => string } -> basename(absolute_name), {:hash_type => :bdb, :dir => dirname(absolute_name)}
	it "normalizes options with a name and a specified directory" do
		opts = { :dir => '/something/else/entirely' }
		name, nopts = Redleaf::HashesStore.normalize_options( '/tmp/thinfist', opts )
		nopts.should == { :hash_type => :bdb, :dir => '/tmp' }
		name.should == 'thinfist'
	end


	context "created with a name" do

		before( :each ) do
			@store = Redleaf::HashesStore.new( 'hashesstore_spec', :new => true )
		end

		it_should_behave_like "a Redleaf::Store"

	end

end

# vim: set nosta noet ts=4 sw=4:
