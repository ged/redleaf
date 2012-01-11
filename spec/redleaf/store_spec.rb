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
require 'redleaf/store'


#####################################################################
###	C O N T E X T S
#####################################################################
describe Redleaf::Store do

	before( :all ) do
		@real_derivatives = Redleaf::Store.derivatives.dup
		setup_logging( :debug )
	end

	before( :each ) do
		Redleaf::Store.derivatives.clear
	end

	after( :all ) do
		reset_logging()
		Redleaf::Store.derivatives.replace( @real_derivatives )
	end


	it "is an abstract class" do
		expect {
			Redleaf::Store.new
		}.to raise_error( NoMethodError, /new/ )
	end


	it "raises an appropriate exception if you try to create a store that isn't present in " +
	   "the local machine's Redland library" do
		unimpl_storeclass = Class.new( Redleaf::Store ) do
			backend :giraffe
		end

		expect {
			unimpl_storeclass.new
		}.to raise_error( Redleaf::FeatureError, /unsupported/ )
	end

	it "can check for support for a specified backend" do
		Redleaf::Store.should_receive( :backends ).
			and_return({ 'memory' => "...since I can't remember triples without a computer" })
		Redleaf::Store.is_supported?( :memory ).should == true
	end

	it "can create its derivatives by name" do
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

	it "can load its derivatives by name" do
		Redleaf::Store.should_receive( :require ).with( 'redleaf/store/giraffe' )

		giraffe_storeclass = Class.new( Redleaf::Store )
		giraffe_storeclass.should_receive( :backends ).
			and_return({ 'giraffe' => "Giraffes like RDF too!" })
		giraffe_storeclass.module_eval do
			backend :giraffe
		end
		giraffe_storeclass.should_receive( :load ).with( 'name' ).and_return( :the_triplestore )

		Redleaf::Store.load( :giraffe, 'name' ).should == :the_triplestore
	end


	describe "concrete subclass" do

		before( :each ) do
			@storeclass = Class.new( Redleaf::Store ) do
				backend :memory
			end
		end

		it "can set which Redland backend to use declaratively" do
			@storeclass.backend.should == :memory
			Redleaf::Store.derivatives.should have(1).member
			Redleaf::Store.derivatives.should include( :memory => @storeclass )
		end

		it "can check for support for the declared backend" do
			@storeclass.should_receive( :backends ).
				and_return({ 'memory' => "...since I can't remember triples without a computer" })

			@storeclass.should be_supported
		end

	end

end

# vim: set nosta noet ts=4 sw=4:
