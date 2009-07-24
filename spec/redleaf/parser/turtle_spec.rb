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
	require 'redleaf/parser/turtle'
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

describe Redleaf::TurtleParser do
	include Redleaf::SpecHelpers


	before( :all ) do
		setup_logging( :fatal )
	end


	before( :each ) do
		pending "no TriG parser type; will not test" unless 
			Redleaf::TurtleParser.is_supported?
	end


	after( :all ) do
		reset_logging()
	end


	describe "instance" do

		before( :each ) do
			@subject = URI( 'http://www.w3.org/TR/rdf-syntax-grammar' )

			@parser = Redleaf::TurtleParser.new
			@baseuri = 'file://' + __FILE__
			@turtle = <<-EOF
			@prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
			@prefix dc:      <http://purl.org/dc/elements/1.1/>.
			@prefix exterms: <http://www.example.org/terms/>.

			<#{subject}> 
			    dc:title "RDF/XML Syntax Specification (Revised)";
			    exterms:editor [
			        exterms:fullName "Dave Beckett";
			        exterms:homePage <http://purl.org/net/dajobe/>
			    ] .
			EOF
		end


		it_should_behave_like "A Parser"


		it "requires that #parse be called with a baseuri" do
			lambda {
				@parser.parse( @turtle )
			}.should raise_error( ArgumentError, /baseuri/i )
		end


		it "parses valid Turtle content and returns a graph" do
			exterms = Redleaf::Namespace.new( 'http://www.example.org/terms/' )

			graph = @parser.parse( @turtle, @baseuri )
			graph.should be_an_instance_of( Redleaf::Graph )
			graph.size.should == 4
			graph.statements.map {|st| st.predicate }.
				should include( DC[:title], exterms[:editor], exterms[:fullName], exterms[:homePage] )
			bnode = graph.object( @subject, exterms[:editor] )

			bnode.should be_a( Symbol )
			graph[ bnode, nil, nil ].should have(2).members
			graph.object( bnode, exterms[:fullName] ).should == 'Dave Beckett'
			graph.object( bnode, exterms[:homePage] ).should == URI('http://purl.org/net/dajobe/')
		end

		it "raises an error when asked to parse invalid input" do
			turtle = <<-EOF
			# prefix name must end in a :
			@prefix a <#> .
			EOF

			lambda {
				@parser.parse( turtle, @baseuri )
			}.should raise_error( Redleaf::ParseError, /1 errors/ )
		end

	end

end

# vim: set nosta noet ts=4 sw=4:
