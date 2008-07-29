#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent

	libdir = basedir + "lib"

	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
}

begin
	require 'spec/runner'
	require 'rdf/redland'
	require 'spec/lib/helpers'
rescue LoadError
	unless Object.const_defined?( :Gem )
		require 'rubygems'
		retry
	end
	raise
end



#####################################################################
###	C O N T E X T S
#####################################################################
describe Redland::Parser do
	include SpecHelpers

	BASE_URI = 'http://www.w3.org/2000/10/rdf-tests/rdfcore/testSchema#'

	before( :all ) do
		setup_logging( :debug )
	end

	before( :each ) do
		@rdfxml_parser = Redland::Parser.new
		@ntriples_parser = Redland::Parser.new( 'ntriples', '' )
		
		@specdir = Pathname.new( __FILE__ ).expand_path.dirname.relative_path_from( Pathname.getwd )
		@datadir = @specdir + 'data'
	end

	after( :all ) do
		reset_logging()
	end

	

	# <!-- amp-in-url/Manifest.rdf -->
	# <test:PositiveParserTest rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/amp-in-url/Manifest.rdf#test001">
	# 	<test:status>APPROVED</test:status>
	# 	<test:approval rdf:resource="http://lists.w3.org/Archives/Public/w3c-rdfcore-wg/2001Sep/0326.html" />
	# 	<test:inputDocument>
	# 		<test:RDF-XML-Document rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/amp-in-url/test001.rdf" />
	# 	</test:inputDocument>
	# 	<test:outputDocument>
	# 		<test:NT-Document rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/amp-in-url/test001.nt" />
	# 	</test:outputDocument>
	# </test:PositiveParserTest>
	it "correctly parses test001 of the amp-in-url section" do
 		input = @datadir + 'amp-in-url/test001.rdf'
		expected = @datadir + 'amp-in-url/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end

	# <!-- rdf-containers-syntax-vs-schema/Manifest.rdf -->
	# <test:NegativeParserTest rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/rdf-containers-syntax-vs-schema/Manifest.rdf#error001">
	#    <test:issue rdf:resource="http://www.w3.org/2000/03/rdf-tracking/#rdf-containers-syntax-vs-schema" />
	#    <test:status>APPROVED</test:status>
	#    <test:approval rdf:resource="http://lists.w3.org/Archives/Public/w3c-rdfcore-wg/2001Jul/0000.html" />
	#    <test:inputDocument>
	#       <test:RDF-XML-Document rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/rdf-containers-syntax-vs-schema/error001.rdf" />
	#    </test:inputDocument>
	# </test:NegativeParserTest>
	it "raises an error when parsing error001 from the rdf-containers-syntax-vs-schema section" do
		input = @datadir + 'rdf-containers-syntax-vs-schema/error001.rdf'
		
		model = Redland::Model.new
		lambda {
			@rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		}.should raise_error()
	end
	

	# <test:PositiveEntailmentTest rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/datatypes-intensional/Manifest.rdf#xsd-integer-string-incompatible">
	#    <test:status>APPROVED</test:status>
	#    <test:approval rdf:resource="http://lists.w3.org/Archives/Public/w3c-rdfcore-wg/2003Sep/0093.html" />
	#    <test:description>
	# The claim that xsd:integer is a subClassOF xsd:string is
	# incompatible with using the intensional semantics for datatypes.
	#    </test:description>
	# 
	#    <test:entailmentRules rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#" />
	#    <test:entailmentRules rdf:resource="http://www.w3.org/2000/01/rdf-schema#" />
	#    <test:entailmentRules rdf:resource="http://www.w3.org/2000/10/rdf-tests/rdfcore/datatypes#" />
	#    <test:datatypeSupport rdf:resource="http://www.w3.org/2001/XMLSchema#integer" />
	#    <test:datatypeSupport rdf:resource="http://www.w3.org/2001/XMLSchema#string" />
	# 
	#    <test:premiseDocument>
	#       <test:NT-Document rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/datatypes-intensional/test002.nt" />
	#    </test:premiseDocument>
	# 
	#    <test:conclusionDocument>
	#       <test:False-Document />
	#    </test:conclusionDocument>
	# </test:PositiveEntailmentTest>
	
	
end

# vim: set nosta noet ts=4 sw=4:
