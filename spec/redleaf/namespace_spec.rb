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
		setup_logging( :debug )
	end

	before( :each ) do
		@namespace = TEST_NAMESPACE.dup
	end
	

	after( :all ) do
		reset_logging()
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
	
end

# vim: set nosta noet ts=4 sw=4:
