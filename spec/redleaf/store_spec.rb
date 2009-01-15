#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent
	
	libdir = basedir + "lib"
	extdir = basedir + "ext"
	
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

gem 'rspec', '>= 1.1.11' # For correct hash-matching in .should include(...)

begin
	require 'spec'
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
		@real_derivatives = Redleaf::Store.derivatives.dup
		setup_logging( :fatal )
	end

	before( :each ) do
		Redleaf::Store.derivatives.clear
	end

	after( :all ) do
		reset_logging()
		Redleaf::Store.derivatives.replace( @real_derivatives )
	end


	it "is an abtract class" do
		lambda {
			Redleaf::Store.new
		}.should raise_error( RuntimeError, /cannot allocate/ )
	end


	it "raises an appropriate exception if you try to create a store that isn't present in " +
	   "the local machine's Redland library" do
		unimpl_storeclass = Class.new( Redleaf::Store ) do
			backend :giraffe
		end
		
		lambda {
			unimpl_storeclass.new
		}.should raise_error( Redleaf::FeatureError, /unsupported/ )
	end


	it "can load its derivatives by name" do
		Redleaf::Store.should_receive( :require ).with( 'redleaf/store/giraffe' )

		giraffe_storeclass = Class.new( Redleaf::Store )
		giraffe_storeclass.should_receive( :backends ).
			and_return({ 'giraffe' => "Giraffes like RDF too!" })
		giraffe_storeclass.module_eval do
			backend :giraffe
		end
		giraffe_storeclass.should_receive( :new ).with( 'name' ).and_return( :the_triplestore )

		Redleaf::Store.create( :giraffe, 'name' ).should == :the_triplestore
	end
	

	describe "concrete subclass" do
		
		it "can set which Redland backend to use declaratively" do
			storeclass = Class.new( Redleaf::Store ) do
				backend :memory
			end
			
			storeclass.backend.should == :memory
			Redleaf::Store.derivatives.should have(1).member
			Redleaf::Store.derivatives.should include( :memory => storeclass )
		end
		
	end

end

# vim: set nosta noet ts=4 sw=4:
