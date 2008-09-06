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
	
	it "converts an xsd:decimal to a BigDecimal" do
		Redleaf::Statement.make_typed_literal_object( XSD[:decimal], "2.1415" ).should == 2.1415
	end

	it "converts an xsd:integer to a Integer" do
		Redleaf::Statement.make_typed_literal_object( XSD[:integer], "18" ).should == 18
	end

	it "converts an xsd:dateTime to a DateTime" do
		Redleaf::Statement.
			make_typed_literal_object( XSD[:dateTime], "2002-10-10T17:00:00Z" ).should == 
			DateTime.parse( "2002-10-10T17:00:00Z" )
	end

	it "converts an xsd:duration to a Duration" do
		Redleaf::Statement.make_typed_literal_object( XSD[:duration], "P1Y2M3DT10H30M" ).should == 
			{ :years => 1, :months => 2, :days => 3, :hours => 10, :minutes => 30, :seconds => 0 }
	end

	it "converts an xsd:duration with a negative sign to a negative Duration" do
		Redleaf::Statement.make_typed_literal_object( XSD[:duration], "-P1Y2M3DT10H30M" ).should == 
			{ :years => -1, :months => -2, :days => -3, :hours => -10, :minutes => -30, :seconds => 0 }
	end

	it "converts an xsd:duration with a decimal seconds value to an equivalent Duration" do
		Redleaf::Statement.make_typed_literal_object( XSD[:duration], "PT8M3.886S" ).should == 
			{ :years => 0, :months => 0, :days => 0, :hours => 0, :minutes => 8, :seconds => 3.886 }
	end


	describe "created with no subject, predicate, or object" do
		
		before( :each ) do
			@statement = Redleaf::Statement.new
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


		# Other stuff

		it "isn't complete" do
			@statement.should_not be_complete()
		end
		
		it "can be stringified" do
			@statement.to_s.should == '{(null), (null), (null)}'
		end
		

		# :TODO: print
		# :TODO: encode
		# :TODO: encode_parts
		# :TODO: decode
		# :TODO: decode_parts
	end


	describe "that has been constructed with a subject, predicate, and object" do

		before( :each ) do
			@subject   = TEST_EMAIL_URL
			@predicate = TEST_FAVORITE_BOOK_URI
			@object    = TEST_ISBN_URN

			@statement = Redleaf::Statement.new( @subject, @predicate, @object )
		end


		it "can be cleared" do
			@statement.clear
			@statement.subject.should be_nil()
			@statement.predicate.should be_nil()
			@statement.object.should be_nil()
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


		it "is complete" do
			@statement.should be_complete()
		end
		
		
		it "can be stringified" do
			@statement.to_s.should == "{[#@subject], [#@predicate], [#@object]}"
		end
		
		# :TODO: print
		# :TODO: encode
		# :TODO: encode_parts
		# :TODO: decode
		# :TODO: decode_parts

	end


	describe " instances that share the same subject, predicate, and object" do
		
		before( :each ) do
			@subject   = TEST_EMAIL_URL
			@predicate = TEST_FAVORITE_BOOK_URI
			@object    = TEST_ISBN_URN

			@statement1 = Redleaf::Statement.new( @subject, @predicate, @object )
			@statement2 = Redleaf::Statement.new( @subject, @predicate, @object )
		end

		it "are == to each other" do
			@statement1.should == @statement2
		end
		
		it "are .eql? to each other" do
			@statement1.should be_eql( @statement2 )
		end

		it "case match each other" do
			@statement1.should === @statement2
		end
	end


	describe " instances with different subjects" do
		
		before( :each ) do
			@subject1  = TEST_EMAIL_URL
			@subject2  = URI.parse('mailto:mahlon@martini.nu')
			@predicate = TEST_FAVORITE_BOOK_URI
			@object    = TEST_ISBN_URN

			@statement1 = Redleaf::Statement.new( @subject1, @predicate, @object )
			@statement2 = Redleaf::Statement.new( @subject2, @predicate, @object )
		end

		it "are not == to each other" do
			@statement1.should_not == @statement2
		end
		
		it "are not .eql? to each other" do
			@statement1.should_not be_eql( @statement2 )
		end

		it "do not case match each other" do
			@statement1.should_not === @statement2
		end
	end


	describe " instances with bnode subjects" do
		
		before( :each ) do
			@predicate = TEST_FAVORITE_BOOK_URI
			@object    = TEST_ISBN_URN

			@statement1 = Redleaf::Statement.new( nil, @predicate, @object )
			@statement2 = Redleaf::Statement.new( nil, @predicate, @object )
		end

		it "are not == to each other" do
			@statement1.should_not == @statement2
		end
		
		it "are not .eql? to each other" do
			@statement1.should_not be_eql( @statement2 )
		end

		it "do not case match each other" do
			@statement1.should_not === @statement2
		end
	end


	describe " instances, one with a NULL subject and one with a set subject" do
		
		before( :each ) do
			@subject   = TEST_EMAIL_URL
			@predicate = TEST_FAVORITE_BOOK_URI
			@object    = TEST_ISBN_URN

			# :TODO: Nil should be a NULL node, and a Symbol should be a labelled bnode
			@statement1 = Redleaf::Statement.new( @subject, @predicate, @object )
			@statement2 = Redleaf::Statement.new
			@statement2.predicate = @predicate
			@statement2.object = @object
		end

		it "are not == to each other" do
			@statement1.should_not == @statement2
		end
		
		it "are not .eql? to each other" do
			@statement1.should_not be_eql( @statement2 )
		end

		it "case match each other" do
			@statement1.should === @statement2
		end

	end

end

# vim: set nosta noet ts=4 sw=4:
