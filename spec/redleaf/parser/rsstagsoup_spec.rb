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
require 'redleaf/parser/rsstagsoup'
require 'redleaf/behavior/parser'


#####################################################################
###	C O N T E X T S
#####################################################################
describe Redleaf::RSSTagSoupParser do

	before( :all ) do
		@specdir     = Pathname( __FILE__ ).dirname.parent.parent
		@specdatadir = @specdir + 'data/rss'
		setup_logging( :fatal )
	end


	before( :each ) do
		pending "no RSSTagSoup parser type; will not test" unless 
			Redleaf::RSSTagSoupParser.is_supported?
	end


	after( :all ) do
		reset_logging()
	end


	describe "instance" do

		before( :each ) do
			setup_logging( :fatal )
			@parser = Redleaf::RSSTagSoupParser.new
		end

		it_should_behave_like "a Redleaf::Parser"


		it "requires that #parse be called with a baseuri" do
			expect {
				@parser.parse( "something" )
			}.to raise_error( ArgumentError, /1 for 2/ )
		end

		it "parses a simple example RSS feed" do
			document = @specdatadir + 'test02.rdf'
			baseuri = URI( 'http://example.org/news/' )

			content = Redleaf::Namespace( 'http://purl.org/rss/1.0/modules/content/' )
			rss = Redleaf::Namespace( 'http://purl.org/rss/1.0/' )

			expected_graph = Redleaf::Graph.new
			expected_graph << {
				baseuri => {
				    DC[:date]         => "2008-03-30T05:52:06Z",
				    rss[:description] => "Example News feed.",
				    rss[:items]       => {
				        RDF[:_1]   => baseuri + '2008-03-30',
				        RDF[:_2]   => baseuri + '2007-10-01',
				        RDF[:type] => RDF[:Seq],
				    },
				    rss[:link]        => "http://example.org/news/",
				    rss[:title]       => "Example News",
					content[:encoded] => "Example News feed.",
					RDF[:type]        => rss[:channel],
				},

				baseuri + '2007-10-01' => {
				    DC[:date]         => "2007-10-01T06:56:58Z",
				    rss[:description] => 
						%{<div xmlns="http://www.w3.org/1999/xhtml">\nhtml description 4\n</div>},
				    rss[:link]        => "http://example.org/news/2007-10-01",
				    content[:encoded] => 
						%{<div xmlns="http://www.w3.org/1999/xhtml">\nhtml description 3\n</div>},
				    rss[:title]       => "News for 2007-10-01",
				    RDF[:type]        => rss[:item],
				},

				baseuri + '2008-03-30' => {
				    DC[:date]         => "2008-03-30T06:07:28Z",
				    rss[:description] => 
						%{<div xmlns="http://www.w3.org/1999/xhtml">\nhtml description 2\n</div>},
				    rss[:link]        => "http://example.org/news/2008-03-30",
				    content[:encoded] => 
						%{<div xmlns="http://www.w3.org/1999/xhtml">\nhtml description 1\n</div>},
				    rss[:title]       => "News for 2008-03-30",
				    RDF[:type]        => rss[:item],
				}
			}

			results = @parser.parse( document.read, baseuri )

			results.should be_a( Redleaf::Graph )
			results.should === expected_graph
		end


		it "raises an error when asked to parse input that doesn't look like RSS of some kind" do
			expect {
				@parser.parse( "something that's not RSS", 'http://example.org/news/' )
			}.to raise_error( Redleaf::ParseError )
		end

	end

end

# vim: set nosta noet ts=4 sw=4:
