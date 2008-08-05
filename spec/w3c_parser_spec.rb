#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent

	libdir = basedir + "lib"

	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
}

begin
	require 'spec/runner'
	require 'redleaf/parser'
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
describe Redleaf::Parser do

	BASE_URI = 'http://www.w3.org/2000/10/rdf-tests/rdfcore/testSchema#'

	before( :all ) do
		@specdir = Pathname.new( __FILE__ ).expand_path.dirname.relative_path_from( Pathname.getwd )
		@datadir = @specdir + 'data'
	end
	
	before( :each ) do
		@parser = Redleaf::Parser.new
	end
	

	# (No description: amp-in-url/Manifest.rdf#test001)

	it "passes the W3C test 'amp-in-url/Manifest.rdf#test001'" do
 		input = @datadir + 'amp-in-url/test001.rdf'
		expected = @datadir + 'amp-in-url/test001.nt'

		input_model = @parser.parse( input.read, BASE_URI )
		expected_model = @parser.parse( expected.read, BASE_URI )
		
		input_model.should == expected_model
	end

end

# vim: set nosta noet ts=4 sw=4:
