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

describe Redleaf::Store do
	include Redleaf::SpecHelpers


	before( :all ) do
		setup_logging( :fatal )
	end


	after( :all ) do
		reset_logging()
	end


	it "is an abtract class" do
		lambda {
			Redleaf::Store.new
		}.should raise_error( RuntimeError, /cannot allocate/ )
	end


	it "raises an appropriate exception if you try to create a store that isn't present in " +
	   "the local machine's Redland library" do
		unimpl_storeclass = Class.new( Redleaf::Store ) do
			backend :giraffes
		end
		
		lambda {
			unimpl_storeclass.new
		}.should raise_error( Redleaf::FeatureError, /unsupported/ )
	end
	

	describe "concrete subclass" do
		
		it "can set which Redland backend to use declaratively" do
			storeclass = Class.new( Redleaf::Store ) do
				backend :memory
			end
			
			storeclass.backend.should == :memory
		end
		
	end

end

# vim: set nosta noet ts=4 sw=4:
