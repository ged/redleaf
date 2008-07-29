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

	BASE_URI = 'http://www.w3.org/2000/10/rdf-tests/rdfcore/testSchema#'

	before( :each ) do
		@rdfxml_parser = Redland::Parser.new
		@ntriples_parser = Redland::Parser.new( 'ntriples', '' )
		
		@specdir = Pathname.new( __FILE__ ).expand_path.dirname.relative_path_from( Pathname.getwd )
		@datadir = @specdir + 'data'
	end


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
	
end

# vim: set nosta noet ts=4 sw=4:
