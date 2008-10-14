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
	require 'redleaf/parser'
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

describe Redleaf::Parser do
	include Redleaf::SpecHelpers


	before( :all ) do
		setup_logging( :fatal )
	end

	after( :all ) do
		reset_logging()
	end


	it "is an abtract class" do
		lambda {
			Redleaf::Parser.new
		}.should raise_error( RuntimeError, /cannot allocate/ )
	end


	it "raises an appropriate exception if you try to create a parser type that isn't present in " +
	   "the local machine's Redland library" do
		unimpl_storeclass = Class.new( Redleaf::Parser ) do
			parser_type :gazelles
		end
		
		lambda {
			unimpl_storeclass.new
		}.should raise_error( Redleaf::FeatureError, /unsupported/ )
	end
	

	it "knows what features the local installation has" do
		features = Redleaf::Parser.features
		
		features.should be_an_instance_of( Hash )
		features.keys.should include( 'ntriples', 'raptor', 'guess' )
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
