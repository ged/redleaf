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
	include Redleaf::SpecHelpers,
		Redleaf::Constants::CommonNamespaces

	BOOK   = Redleaf::Namespace.new( 'http://purl.org/net/schemas/book/' )

	TEST_ISBN_URN          = URI.parse( 'urn:isbn:0297783297' )
	TEST_EMAIL_URL         = URI.parse( 'mailto:ged@FaerieMUD.org' )
	TEST_FAVORITE_BOOK_URI = BOOK[:favourite]

	before( :all ) do
		setup_logging( :fatal )
	end


	after( :all ) do
		reset_logging()
	end


	it "converts an xsd:string to a String" do
		Redleaf::Statement.make_typed_literal_object( XSD[:string], "a string" ).should == 'a string'
	end
	

	it "converts an xsd:float to a Float" do
		Redleaf::Statement.make_typed_literal_object( XSD[:float], "2.1415" ).should == 2.1415
	end
	

	# Subject
	
	describe "created with no subject, predicate, or object" do
		
		before( :each ) do
			@statement = Redleaf::Statement.new
		end
	

		it "allows its subject to be set to a URI" do
			deveiate = URI.parse( 'http://deveiate.org/' )
			@statement.subject = deveiate
			@statement.subject.should == deveiate
		end
	

		it "allows its subject to be set to a blank node" do
			@statement.subject = nil
			@statement.subject.should be_nil()
		end

	
		it "does not allow its subject to be set to a literal" do
			lambda {
				@statement.subject = 11.411
			}.should raise_error( ArgumentError, /subject must be blank or a URI/i )
		end


		# Predicate

		it "allows its predicate to be set to a URI" do
			@statement.predicate = TEST_FAVORITE_BOOK_URI
			@statement.predicate.should == TEST_FAVORITE_BOOK_URI
		end
	
		it "does not allow its predicate to be set to a blank node" do
			lambda {
				@statement.predicate = nil
			}.should raise_error( ArgumentError, /predicate must be a URI/i )
		end
	
		it "does not allow its predicate to be set to a literal" do
			lambda {
				@statement.predicate = "some literal value"
			}.should raise_error( ArgumentError, /predicate must be a URI/i )
		end
	


		# Object

		it "allows its object to be set to a URI"  do
			@statement.object = TEST_ISBN_URN
			@statement.object.should == TEST_ISBN_URN
		end
		
		it "allows its object to be set to a blank node"  do
			@statement.object = nil
			@statement.object.should == nil
		end
		
		it "allows its object to be set to a plain literal"  do
			@statement.object = "Leaves of Grass"
			@statement.object.should == "Leaves of Grass"
		end
		
		it "allows its object to be set to a Fixnum"  do
			@statement.object = 18
			@statement.object.should == 18
		end
		
		it "allows its object to be set to a Float"  do
			@statement.object = 14.4
			@statement.object.should == 14.4
		end
		
		it "allows its object to be set to true"  do
			@statement.object = true
			@statement.object.should == true
		end
		
		it "allows its object to be set to false"  do
			@statement.object = false
			@statement.object.should == false
		end
		

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


	describe "that has been constructed with a subject, predicate, and object" do

		before( :each ) do
			@subject   = TEST_EMAIL_URL
			@predicate = TEST_FAVORITE_BOOK_URI
			@object    = TEST_ISBN_URN

			@statement = Redleaf::Statement.new( @subject, @predicate, @object )
		end


		it "has its subject set" do
			@statement.subject.should == @subject
		end
		

		it "has its predicate set" do
			@statement.predicate.should == @predicate
		end
		

		it "has its object set" do
			@statement.object.should == @object
		end


		# is_complete
		# to_string
		# print
		# equals
		# match
		# encode
		# encode_parts
		# decode
		# decode_parts


		it "can be cleared" do
			@statement.clear
			@statement.subject.should be_nil()
			@statement.predicate.should be_nil()
			@statement.object.should be_nil()
		end
	
	end

	


end

# vim: set nosta noet ts=4 sw=4:
