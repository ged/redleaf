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
require 'redleaf/parser/grddl'
require 'redleaf/behavior/parser'


#####################################################################
###	C O N T E X T S
#####################################################################
describe Redleaf::GRDDLParser do

	before( :all ) do
		@specdir     = Pathname( __FILE__ ).dirname.parent.parent
		@specdatadir = @specdir + 'data/grddl'
		setup_logging( :fatal )
	end


	before( :each ) do
		pending "no GRDDL parser type; will not test" unless 
			Redleaf::GRDDLParser.is_supported?
	end


	after( :all ) do
		reset_logging()
	end


	describe "instance" do

		before( :each ) do
			@parser = Redleaf::GRDDLParser.new
		end


		it_should_behave_like "a Redleaf::Parser"


		it "requires that #parse be called with a baseuri" do
			expect {
				@parser.parse( "something" )
			}.to raise_error( ArgumentError, /1 for 2/ )
		end


		it "parses valid XML with an embedded GRDDL profile and returns a graph" do
			document = Pathname( 'xmlWithGrddlAttribute.xml' )
			baseuri = URI( "file:#{document}" )

			ns0 = Redleaf::Namespace( 'http://www.w3.org/2002/01/' )
			expected_graph = Redleaf::Graph.new
			expected_graph << {
				baseuri => { 
					ns0[:P3Pv1expiry] => {
				        ns0[:"P3Pv1max-age"] => "604800"
					},
				},

				URI( "#{baseuri}#public" ) => {
					RDF[:type] => ns0[:P3Pv1Policy],
					ns0[:P3Pv1discuri] => URI('http://www.w3.org/Consortium/Legal/privacy-statement#Public'),
				}
			}

			### :FIXME: Need to figure out a better way to do this than changing directories
			results = nil
			Dir.chdir( @specdatadir ) do
				results = @parser.parse( document.read, baseuri )
			end

			results.should be_a( Redleaf::Graph )
			results.should === expected_graph
		end

	end

end

# vim: set nosta noet ts=4 sw=4:
