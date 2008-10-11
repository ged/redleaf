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
	require 'redleaf/utils'
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

describe Redleaf::NodeUtils do
	include Redleaf::SpecHelpers
	
	before( :all ) do
		setup_logging( :fatal )
	end
	
	after( :all ) do
		reset_logging()
	end



	it "converts an xsd:string to a String" do
		Redleaf::NodeUtils.make_typed_literal_object( XSD[:string], "a string" ).should == 'a string'
	end


	it "converts an xsd:float to a Float" do
		Redleaf::NodeUtils.make_typed_literal_object( XSD[:float], "2.1415" ).should == 2.1415
	end

	it "converts an xsd:decimal to a BigDecimal" do
		Redleaf::NodeUtils.make_typed_literal_object( XSD[:decimal], "2.1415" ).should == 2.1415
	end

	it "converts an xsd:integer to a Integer" do
		Redleaf::NodeUtils.make_typed_literal_object( XSD[:integer], "18" ).should == 18
	end

	it "converts an xsd:dateTime to a DateTime" do
		Redleaf::NodeUtils.
			make_typed_literal_object( XSD[:dateTime], "2002-10-10T17:00:00Z" ).should == 
			DateTime.parse( "2002-10-10T17:00:00Z" )
	end

	it "converts an xsd:duration to a Duration" do
		Redleaf::NodeUtils.make_typed_literal_object( XSD[:duration], "P1Y2M3DT10H30M" ).should == 
			{ :years => 1, :months => 2, :days => 3, :hours => 10, :minutes => 30, :seconds => 0 }
	end

	it "converts an xsd:duration with a negative sign to a negative Duration" do
		Redleaf::NodeUtils.make_typed_literal_object( XSD[:duration], "-P1Y2M3DT10H30M" ).should == 
			{ :years => -1, :months => -2, :days => -3, :hours => -10, :minutes => -30, :seconds => 0 }
	end

	it "converts an xsd:duration with a decimal seconds value to an equivalent Duration" do
		Redleaf::NodeUtils.make_typed_literal_object( XSD[:duration], "PT8M3.886S" ).should == 
			{ :years => 0, :months => 0, :days => 0, :hours => 0, :minutes => 8, :seconds => 3.886 }
	end


end


# vim: set nosta noet ts=4 sw=4:
