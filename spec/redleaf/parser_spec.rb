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


	it "knows what features the local installation has" do
		features = Redleaf::Parser.features
		
		features.should be_an_instance_of( Hash )
		features.keys.should include( 'ntriples', 'raptor', 'guess' )
	end


	describe "instance (with defaults)" do
		before( :each ) do
			@parser = Redleaf::Parser.new
		end
		
		
		it "can build an accept header for the kinds of content it accepts" do
			@parser.accept_header.should =~ %r{application/rdf\+xml}i
		end

		it "description" do
			
		end
		
		
	end

end

# vim: set nosta noet ts=4 sw=4:
