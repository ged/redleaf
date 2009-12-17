#!/usr/bin/env ruby

BEGIN {
	require 'rbconfig'
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent
	
	libdir = basedir + "lib"
	extdir = libdir + Config::CONFIG['sitearch']
	
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

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

describe "A QueryResult", :shared => true do
	include Redleaf::SpecHelpers


	it "supports Enumerable" do
		@result.should respond_to( :each )
	end
	
	it "can return an XML representation of itself" do
		@result.to_xml.should =~ %r{<\?xml.version=\"1.0\".*}mx
	end
	
	it "can return a JSON representation of itself" do
		begin
			require 'json'
		rescue LoadError
			pending "local installation of the 'ruby-json' library"
		else
			JSON.parse( @result.to_json ).should be_an_instance_of( Hash )
		end
	end
	
end


# vim: set nosta noet ts=4 sw=4:
