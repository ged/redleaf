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
require 'redleaf/parser/trig'
require 'redleaf/behavior/parser'


#####################################################################
###	C O N T E X T S
#####################################################################
describe Redleaf::TriGParser do

	before( :all ) do
		@specdir     = Pathname( __FILE__ ).dirname.parent.parent
		@specdatadir = @specdir + 'data/trig'
		setup_logging( :fatal )
	end


	before( :each ) do
		pending "no TriG parser type; will not test" unless 
			Redleaf::TriGParser.is_supported?
	end


	after( :all ) do
		reset_logging()
	end


	describe "instance" do

		before( :each ) do
			setup_logging( :fatal )
			@parser = Redleaf::TriGParser.new
		end


		it_should_behave_like "a Redleaf::Parser"


		it "parses valid TriG content and returns a graph" do
			document = @specdatadir + 'example1.trig'
			baseuri = URI( 'http://example.org/news/' )

			content = Redleaf::Namespace( 'http://purl.org/rss/1.0/modules/content/' )
			rss = Redleaf::Namespace( 'http://purl.org/rss/1.0/' )

			swp = Redleaf::Namespace( 'http://www.w3.org/2004/03/trix/swp-1/' )
			ex  = Redleaf::Namespace( 'http://www.example.org/vocabulary#' )
			ns0 = Redleaf::Namespace( 'http://www.example.org/exampleDocument#' )

			expected_graph = Redleaf::Graph.new
			expected_graph << 
				[ ns0[:Monica], ex[:name],			"Monica Murphy" ] <<
				[ ns0[:Monica], ex[:homepage],		URI('http://www.monicamurphy.org') ] <<
				[ ns0[:Monica], ex[:email],			URI('mailto:monica@monicamurphy.org') ] <<
				[ ns0[:Monica], ex[:hasSkill],		ex[:Management] ] <<
				[ ns0[:Monica], RDF[:type],			ex[:Person] ] <<
				[ ns0[:Monica], ex[:hasSkill],		ex[:Programming] ] <<
				[ ns0[:G1],		swp[:assertedBy],	:_w1 ] <<
				[ :_w1, 		swp[:authority], 	ns0[:Chris] ] <<
				[ :_w1, 		DC[:date],			Date.parse("2003-10-02") ] <<
				[ ns0[:G2],		swp[:quotedBy],		:_w2 ] <<
				[ ns0[:G3],		swp[:assertedBy],	:_w2 ] <<
				[ :_w2, 		DC[:date], 			Date.parse("2003-09-03") ] <<
				[ :_w2,			swp[:authority],	ns0[:Chris] ] <<
				[ ns0[:Chris],	RDF[:type],			ex[:Person] ] <<
				[ ns0[:Chris],	ex[:email],			URI('mailto:chris@bizer.de') ]

			results = @parser.parse( document.read, baseuri )

			results.should be_a( Redleaf::Graph )
			results.should === expected_graph
		end

		it "raises an error when asked to parse invalid input" do
			expect {
				@parser.parse( "Fooooom!" )
			}.to raise_error( Redleaf::ParseError )
		end

	end

end

# vim: set nosta noet ts=4 sw=4:
