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
	require 'spec'
	require 'spec/lib/constants'
	require 'spec/lib/helpers'

	require 'redleaf'
	require 'redleaf/namespace'
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

describe Redleaf::Namespace do
	include Redleaf::SpecHelpers


	before( :all ) do
		setup_logging( :fatal )
	end

	after( :all ) do
		reset_logging()
	end


	it "provides a shortcut constructor" do
		Redleaf::Namespace[ 'http://xmlns.com/foaf/0.1/' ].
			should be_an_instance_of( Redleaf::Namespace )
	end
	

	describe "for a directory-style namespace URI" do

		before( :each ) do
			@namespace = Redleaf::Namespace.new( 'http://xmlns.com/foaf/0.1/' )
		end
	

		it "returns its stringified URI when stringified" do
			@namespace.to_s.should == @namespace.uri.to_s
		end

		it "returns terms qualified relative to the namespace" do
			@namespace[ 'Person' ].to_s.should == @namespace.uri.to_s + 'Person'
		end

		it "accepts Symbols as terms as well as Strings" do
			@namespace[ :member_name ].to_s.should == @namespace.uri.to_s + 'member_name'
		end
		
		it "knows it's not a fragment-style namespace" do
			@namespace.should_not be_fragment_style()
		end
		
	end	
	
	
	describe "for a fragment-style namespace URI" do

		before( :each ) do
			@namespace = Redleaf::Namespace.new( 'http://www.w3.org/2001/XMLSchema#' )
		end
	

		it "returns its stringified URI when stringified" do
			@namespace.to_s.should == @namespace.uri.to_s
		end

		it "returns terms qualified relative to the namespace" do
			@namespace[ 'integer' ].to_s.should == @namespace.uri.to_s + 'integer'
		end

		it "accepts Symbols as terms as well as Strings" do
			@namespace[ :string ].to_s.should == @namespace.uri.to_s + 'string'
		end

		it "knows it's a fragment-style namespace" do
			@namespace.should be_fragment_style()
		end
		
	end	
	
	
end

# vim: set nosta noet ts=4 sw=4:
