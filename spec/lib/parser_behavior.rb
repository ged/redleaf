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

describe "A Parser", :shared => true do
	include Redleaf::SpecHelpers


	it "knows which Redland backend it uses" do
		@parser.class.parser_type.should_not be_nil()
	end
	
	it "knows what an accept header for the kinds of content it accepts is" do
		@parser.accept_header.should =~ %r{(?:application|text|\*)/\S+}i
	end

end


# vim: set nosta noet ts=4 sw=4:
