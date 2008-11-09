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
	require 'redleaf/parser/rdfxml'
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

describe Redleaf::RDFXMLParser do
	include Redleaf::SpecHelpers


	before( :all ) do
		setup_logging( :fatal )
	end


	before( :each ) do
		pending "no rdfxml parser type; will not test" unless 
			Redleaf::RDFXMLParser.is_supported?
	end
	

	after( :all ) do
		reset_logging()
	end


	describe "instance" do
		
		before( :each ) do
			setup_logging( :fatal )
			@parser = Redleaf::RDFXMLParser.new
		end
		
		
		it_should_behave_like "A Parser"
		

		it "parses valid RDF/XML and returns a graph" do
			rdfxml = <<-EOF
			<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			         xmlns:dc="http://purl.org/dc/elements/1.1/">
			  <rdf:Description rdf:about="http://www.w3.org/2001/sw/RDFCore/ntriples/">
			    <dc:creator>Art Barstow</dc:creator>
			    <dc:creator>Dave Beckett</dc:creator>
			    <dc:publisher rdf:resource="http://www.w3.org/"/>
			  </rdf:Description>
			</rdf:RDF>
			EOF

			graph = @parser.parse( rdfxml, 'a' )
			graph.should be_an_instance_of( Redleaf::Graph )
			graph.size.should == 3
			graph.statements.map {|st| st.predicate }.
				should include( DC[:creator], DC[:publisher] )
		end
		
		it "raises an error when asked to parse invalid RDF/XML input" do
			not_rdfxml = "I like bees. No, BEEEEEEEES!"
			lambda {
				@parser.parse( not_rdfxml, 'a' )
			}.should raise_error( Redleaf::ParseError, /1 error/i )
		end
	end

end

# vim: set nosta noet ts=4 sw=4:
