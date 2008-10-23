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
	require 'redleaf/queryresult'
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

describe Redleaf::QueryResult do
	include Redleaf::SpecHelpers


	before( :all ) do
		setup_logging( :fatal )
	end

	after( :all ) do
		reset_logging()
	end


	it "is an abtract class" do
		lambda {
			Redleaf::QueryResult.new
		}.should raise_error( NoMethodError, /new/ )
	end


	it "knows what result formatters the local installation supports" do
		res = Redleaf::QueryResult.formatters
		
		res.should be_an_instance_of( Hash )
		res.keys.should include( 'xml' )
	end

end

# vim: set nosta noet ts=4 sw=4:
