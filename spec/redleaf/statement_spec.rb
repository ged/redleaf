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
	require 'redleaf/statement'
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

describe Redleaf::Statement do
	include Redleaf::SpecHelpers

	BOOK = Redleaf::Namespace.new( 'http://purl.org/net/schemas/book/' )

	before( :all ) do
		setup_logging( :fatal )
	end


	before( :each ) do
		@subject = URI.parse( 'mailto:ged@FaerieMUD.org' )
		@predicate = BOOK['favourite']
		@object = URI.parse( 'urn:isbn:0297783297' )
		@statement = Redleaf::Statement.new( @subject, @predicate, @object )
	end
	

	after( :all ) do
		reset_logging()
	end


	it "can be cleared" do
		@statement.clear
		@statement.subject.should be_nil()
		@statement.predicate.should be_nil()
		@statement.object.should be_nil()
	end
	
	
	# Subject
	
	it "allows its subject to be set to a URI" do
		deveiate = URI.parse( 'http://deveiate.org/' )
		@statement.subject = deveiate
		@statement.subject.should == deveiate
	end
	

	it "allows its subject to be set to a blank node" do
		@statement.subject = nil
		@statement.subject.should be_nil()
	end

	
	it "does not allow its subject to be set to a literal"


	# Predicate

	it "allows its predicate to be set to a URI"
	it "does not allow its predicate to be set to a blank node"
	it "does not allow its predicate to be set to a literal"


	# Object

	it "allows its object to be set to a URI"
	it "allows its object to be set to a blank node"
	it "allows its object to be set to a plain literal"
	it "allows its object to be set to a Fixnum"
	it "allows its object to be set to a Float"
	it "allows its object to be set to true"
	it "allows its object to be set to false"


	# is_complete
	# to_string
	# print
	# equals
	# match
	# encode
	# encode_parts
	# decode
	# decode_parts


end

# vim: set nosta noet ts=4 sw=4:
