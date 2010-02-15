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

	TEST_EMAIL_URL         = URI( 'mailto:ged@FaerieMUD.org' )
	TEST_FAVORITE_BOOK_URI = BOOK[:favourite]
	TEST_ISBN_URN          = URI( 'urn:isbn:0297783297' )

	TEST_PROJECT_URI       = URI( 'http://deveiate.org/projects/Redleaf' )
	TEST_PROJECTNAME_URI   = DOAP[:name]
	TEST_PROJECT_NAME      = 'Redleaf'

	before( :all ) do
		setup_logging( :fatal )
	end

	after( :all ) do
		reset_logging()
	end


	describe "factory constructor" do

		before( :each ) do
			@subject    = TEST_EMAIL_URL
			@predicate  = TEST_FAVORITE_BOOK_URI
			@object     = TEST_ISBN_URN

			@subject2   = TEST_PROJECT_URI
			@predicate2 = TEST_PROJECTNAME_URI
			@object2    = TEST_PROJECT_NAME
		end

		it "returns an existing statement as-is" do
			stmt = Redleaf::Statement.new
			Redleaf::Statement.create( stmt ).should == [ stmt ]
		end

		it "returns a single-statement Array when given a simple [subject, predicate, object] Array" do
			Redleaf::Statement.create([ @subject, @predicate, @object ]).should ==
				[ Redleaf::Statement.new(@subject, @predicate, @object) ]
		end

		it "returns a two-statement Array when given an array of two simple [s,p,o] Arrays" do
			array = [
				[ @subject, @predicate, @object ],
				[ @subject2, @predicate2, @object2 ],
			]
			res = Redleaf::Statement.create( array )
			res.should have( 2 ).members

			res.collect {|st| st.subject }.should include( @subject, @subject2 )
			res.collect {|st| st.predicate }.should include( @predicate, @predicate2 )
			res.collect {|st| st.object }.should include( @object, @object2 )
		end

		it "returns a pair of statements with the same subject when given a semi-colon style " +
		   "hash" do
			# <subject> <predicate1> <object1> ;  | { :subject => { <predicate1> => <object1>,
			#           <predicate2> <object2> .  |                 <predicate2> => <object2> }
			hash = { @subject => { @predicate => @object,
			                       @predicate2 => @object2 } }
			res = Redleaf::Statement.create( hash )

			res.should be_an( Array )
			res.should have( 2 ).members

			res.collect {|st| st.subject }.should == [ @subject, @subject ] # Both the same
			res.collect {|st| st.predicate }.should include( @predicate, @predicate2 )
			res.collect {|st| st.object }.should include( @object, @object2 )
		end

		it "returns a pair of statements with the same subject and predicate when given a " +
		   "coma-style hash" do
			# <subject> <predicate1> <object1> ,  | { :subject => 
			#                        <object2> .  |        { <predicate1> => [<object1>, <object2>] }}
			hash = { @subject => {@predicate => [ @object, @object2 ]} }
			res = Redleaf::Statement.create( hash )

			res.should be_an( Array )
			res.should have( 2 ).members

			res.collect {|st| st.subject }.should == [ @subject, @subject ] # Both the same
			res.collect {|st| st.predicate }.should include( @predicate, @predicate )
			res.collect {|st| st.object }.should include( @object, @object2 )
		end

		it "returns statements that make up a graph for a complex hash" do
			# @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
			# @prefix dc: <http://purl.org/dc/elements/1.1/> .
			# @prefix ex: <http://example.org/stuff/1.0/> .
			# 
			# <http://www.w3.org/TR/rdf-syntax-grammar>
			#   dc:title "RDF/XML Syntax Specification (Revised)" ;
			#   ex:editor [
			#     ex:fullname "Dave Beckett";
			#     ex:homePage <http://purl.org/net/dajobe/>
			#   ] .
			ex = Redleaf::Namespace( 'http://example.org/stuff/1.0/' )
			graph = {
				URI('http://www.w3.org/TR/rdf-syntax-grammar') => {
					DC[:title] => "RDF/XML Syntax Specification (Revised)",
					ex[:editor] => {
						ex[:fullname] => 'Dave Beckett',
						ex[:homePage] => URI('http://purl.org/net/dajobe/'),
					}
				}
			}

			res = Redleaf::Statement.create( graph ).sort
			bnode = res.first.object

			res.should be_an( Array )
			res.should have( 4 ).members

			res[0].subject.should == URI( 'http://www.w3.org/TR/rdf-syntax-grammar' )
			res[0].predicate.should == ex[:editor]
			res[0].object.should be_a( Symbol )

			res[1].subject.should == URI( 'http://www.w3.org/TR/rdf-syntax-grammar' )
			res[1].predicate.should == DC[:title]
			res[1].object.should == "RDF/XML Syntax Specification (Revised)"

			res[2].subject.should == bnode
			res[2].predicate.should == ex[:fullname]
			res[2].object.should == 'Dave Beckett'

			res[3].subject.should == bnode
			res[3].predicate.should == ex[:homePage]
			res[3].object.should == URI('http://purl.org/net/dajobe/')
		end


	end


	describe "created with no subject, predicate, or object" do

		before( :each ) do
			@statement = Redleaf::Statement.new
		end


		# Subject

		it "allows its subject to be set to a URI" do
			deveiate = URI( 'http://deveiate.org/' )
			@statement.subject = deveiate
			@statement.subject.should == deveiate
		end


		it "allows its subject to be set to a named blank node" do
			@statement.subject = :blanknode
			@statement.subject.should == :blanknode
		end


		it "allows its subject to be set to an anonymous blank node" do
			@statement.subject = :_
			@statement.subject.should_not == :_
			@statement.subject.should be_an_instance_of( Symbol )
		end


		it "allows its subject to be set to a URI string" do
			@statement.subject = 'http://example.org/'
			@statement.subject.should == URI('http://example.org/')
		end


		it "allows its subject to be set to a Redleaf::Namespace" do
			ns = Redleaf::Namespace.new( 'http://example.org/' )
			@statement.subject = ns
			@statement.subject.should == URI('http://example.org/')
		end


		it "does not allow its subject to be set to a literal" do
			lambda {
				@statement.subject = 11.411
			}.should raise_error( ArgumentError, /subject must be blank or a URI/i )
		end


		it "allows its subject to be cleared by setting it to nil" do
			@statement.subject = nil
			@statement.subject.should == nil
		end


		# Predicate

		it "allows its predicate to be set to a URI" do
			@statement.predicate = TEST_FAVORITE_BOOK_URI
			@statement.predicate.should == TEST_FAVORITE_BOOK_URI
		end

		it "allows its predicate to be set to a URI string" do
			@statement.predicate = TEST_FAVORITE_BOOK_URI.to_s
			@statement.predicate.should == TEST_FAVORITE_BOOK_URI
		end


		it "allows its subject to be set to a Redleaf::Namespace" do
			ns = Redleaf::Namespace.new( TEST_FAVORITE_BOOK_URI )
			@statement.predicate = ns
			@statement.predicate.should == TEST_FAVORITE_BOOK_URI
		end

		it "does not allow its predicate to be set to a blank node" do
			lambda {
				@statement.predicate = :glar
			}.should raise_error( ArgumentError, /predicate must be a URI/i )
		end

		it "does not allow its predicate to be set to a literal" do
			lambda {
				@statement.predicate = Time.now
			}.should raise_error( ArgumentError, /predicate must be a URI/i )
		end

		it "allows its predicate to be cleared by setting it to nil" do
			@statement.predicate = nil
			@statement.predicate.should == nil
		end


		# Object

		it "allows its object to be set to a URI"  do
			@statement.object = TEST_ISBN_URN
			@statement.object.should == TEST_ISBN_URN
		end

		it "allows its object to be set to a named blank node"  do
			@statement.object = :blanknode
			@statement.object.should == :blanknode
		end

		it "allows its object to be set to an anonymous blank node"  do
			@statement.object = :_
			@statement.object.should_not == :_
			@statement.object.should be_an_instance_of( Symbol )
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

		it "can be serialized" do
			Marshal.load( Marshal.dump(@statement) ).should == @statement
		end

		it "case-matches an Array with identical nodes" do
			@statement.should === [ @subject, @predicate, @object ]
		end

		it "case-matches an Array with a placeholder subject" do
			@statement.should === [ nil, @predicate, @object ]
		end

		it "case-matches an Array with a placeholder predicate" do
			@statement.should === [ @subject, nil, @object ]
		end

		it "case-matches an Array with a placeholder object" do
			@statement.should === [ @subject, @predicate, nil ]
		end
	end


	describe " instances that share the same subject, predicate, and object" do

		before( :all ) do
			setup_logging( :fatal )
		end

		after( :all ) do
			reset_logging()
		end

		before( :each ) do
			@subject   = TEST_EMAIL_URL
			@predicate = TEST_FAVORITE_BOOK_URI
			@object    = TEST_ISBN_URN

			@statement1 = Redleaf::Statement.new( @subject.dup, @predicate.dup, @object.dup )
			@statement2 = Redleaf::Statement.new( @subject.dup, @predicate.dup, @object.dup )
		end


		it "are == to each other" do
			@statement1.should == @statement2
		end

		it "are .eql? to each other" do
			@statement1.should be_eql( @statement2 )
		end

		it "hash to the same value" do
			@statement1.hash.should == @statement2.hash
		end

		it "case-match each other" do
			@statement1.should === @statement2
			@statement2.should === @statement1
		end

		it "sort as equal" do
			(@statement1 <=> @statement2).should == 0
		end

	end


	describe " instances with different URI subjects" do

		before( :each ) do
			@subject1  = TEST_EMAIL_URL
			@subject2  = URI('mailto:mahlon@martini.nu')
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

		it "do not case-match each other" do
			@statement1.should_not === @statement2
		end

		it "sort on the subject" do
			@statement2.should > @statement1
		end

	end


	describe " instances with null subjects" do

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

		it "case-match each other" do
			@statement1.should === @statement2
		end

		it "sort on the subject" do
			( @statement1 <=> @statement2 ).should == 0
		end

	end


	describe " instances, one with a null subject and one with a set subject" do

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

		it "case-match each other" do
			@statement1.should === @statement2
		end

		it "sort with the null subject first" do
			@statement1.should > @statement2
		end

	end

	describe " instances with the same typed literal object" do
		before( :all ) do
			setup_logging( :fatal )
		end

		after( :all ) do
			reset_logging()
		end

		before( :each ) do
			# Values from the 'datatypes/test001.rdf' W3C test
			@subject   = URI( 'http://example.org/foo' )
			@predicate = URI( 'http://example.org/baz' )
			@object    = 10 # ^^<http://www.w3.org/2001/XMLSchema#integer>

			@statement1 = Redleaf::Statement.new( @subject, @predicate, @object )
			@statement2 = Redleaf::Statement.new( @subject, @predicate, @object )
		end


		it "are == to each other" do
			@statement1.should == @statement2
		end

	end

end

# vim: set nosta noet ts=4 sw=4:
