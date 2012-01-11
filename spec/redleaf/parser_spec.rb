#!/usr/bin/env ruby

BEGIN {
	require 'rbconfig'
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent

	libdir = basedir + "lib"
	extdir = libdir + Config::CONFIG['sitearch']

	$LOAD_PATH.unshift( basedir ) unless $LOAD_PATH.include?( basedir )
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

require 'rspec'

require 'spec/lib/helpers'

require 'redleaf'
require 'redleaf/parser'


#####################################################################
###	C O N T E X T S
#####################################################################
describe Redleaf::Parser do

	before( :all ) do
		setup_logging( :fatal )
	end

	after( :each ) do
		Redleaf::Parser.subclasses.reject! {|klass| !klass.is_a?(Class) }
	end

	after( :all ) do
		reset_logging()
	end


	it "uses the 'guess' parser" do
		Redleaf::Parser.parser_type == :guess
	end


	it "raises an appropriate exception if you try to create a parser type that isn't present in " +
	   "the local machine's Redland library" do
		unimpl_storeclass = Class.new( Redleaf::Parser ) do
			parser_type :gazelles
		end

		expect {
			unimpl_storeclass.new
		}.to raise_error( Redleaf::FeatureError, /unsupported/ )
	end


	it "knows what features the local installation has" do
		features = Redleaf::Parser.features

		features.should be_an_instance_of( Hash )
		features.keys.should include( 'ntriples', 'raptor', 'guess' )
	end


	it "can find derivatives of itself by name" do
		subclass = mock( "Mock Redleaf::Parser Subclass" )

		Redleaf::Parser.should_receive( :require ).with( 'redleaf/parser/fake' ).and_return {
			Redleaf::Parser.inherited( subclass )
		}
		subclass.should_receive( :parser_type ).and_return( :fake )

		Redleaf::Parser.find_by_name( 'fake' ).should == subclass
	end


	it "ignores LoadErrors when attempting to find derivatives of itself by name" do
		expect { Redleaf::Parser.find_by_name('elephants') }.to_not raise_error()
	end


	describe "concrete subclass" do

		it "can set which Redland parser type to use declaratively" do
			parserclass = Class.new( Redleaf::Parser ) do
				parser_type :ntriples
			end

			parserclass.parser_type.should == :ntriples
		end

	end

end

# vim: set nosta noet ts=4 sw=4:
