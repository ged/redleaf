#!/usr/bin/env ruby

BEGIN {
	require 'rbconfig'
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent.parent

	libdir = basedir + "lib"
	extdir = libdir + Config::CONFIG['sitearch']

	$LOAD_PATH.unshift( basedir ) unless $LOAD_PATH.include?( basedir )
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

require 'rspec'

require 'spec/lib/helpers'

require 'redleaf'
require 'redleaf/parser/ntriples'
require 'redleaf/behavior/parser'


#####################################################################
###	C O N T E X T S
#####################################################################
describe Redleaf::NTriplesParser do

	before( :all ) do
		setup_logging( :fatal )
	end

	before( :each ) do
		pending "no ntriples parser type; will not test" unless 
			Redleaf::NTriplesParser.is_supported?
	end

	after( :all ) do
		reset_logging()
	end


	describe "instance" do

		before( :each ) do
			setup_logging( :fatal )
			@parser = Redleaf::NTriplesParser.new
		end


		it_should_behave_like "a Redleaf::Parser"


		it "parses valid NTriples and returns a graph" do
			ntriples = <<-EOF
			<http://www.w3.org/2001/sw/RDFCore/ntriples/> <http://purl.org/dc/elements/1.1/creator> "Dave Beckett" .
			<http://www.w3.org/2001/sw/RDFCore/ntriples/> <http://purl.org/dc/elements/1.1/creator> "Art Barstow" .
			<http://www.w3.org/2001/sw/RDFCore/ntriples/> <http://purl.org/dc/elements/1.1/publisher> <http://www.w3.org/> .
			EOF

			graph = @parser.parse( ntriples )
			graph.should be_an_instance_of( Redleaf::Graph )
			graph.size.should == 3
			graph.statements.map {|st| st.predicate }.
				should include( DC[:creator], DC[:publisher] )
		end

		it "raises an error when asked to parse invalid NTriples input" do
			not_ntriples = "I like bees. No, BEEEEEEEES!"
			expect {
				@parser.parse( not_ntriples )
			}.to raise_error( Redleaf::ParseError, /parse/ )
		end
	end

end

# vim: set nosta noet ts=4 sw=4:
