#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent.parent
	
	libdir = basedir + "lib"
	extdir = basedir + "ext"
	
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

begin
	require 'spec'
	require 'spec/lib/constants'
	require 'spec/lib/helpers'
	require 'spec/lib/parser_behavior'

	require 'redleaf'
	require 'redleaf/parser/rsstagsoup'
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

describe Redleaf::RSSTagSoupParser do
	include Redleaf::SpecHelpers


	before( :all ) do
		setup_logging( :fatal )
	end


	before( :each ) do
		pending "no RSSTagSoup parser type; will not test" unless 
			Redleaf::RSSTagSoupParser.is_supported?
	end
	

	after( :all ) do
		reset_logging()
	end


	describe "instance" do
		
		before( :each ) do
			setup_logging( :fatal )
			@parser = Redleaf::RSSTagSoupParser.new
		end
		
		
		it_should_behave_like "A Parser"
		

		it "parses sloppy RSS tag soup and returns a graph"
		it "raises an error when asked to parse input that doesn't look like RSS of some kind"

	end

end

# vim: set nosta noet ts=4 sw=4:
