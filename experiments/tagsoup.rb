#!/usr/bin/env ruby

# Experimenting with the rsstagsoup parser. Requires that the test suite from
# the Universal Feed Parser (http://feedparser.googlecode.com/files/feedparser-tests-4.1.zip) 
# be unzipped  into spec/data/feedparser-tests-4.1

BEGIN {
	require 'rbconfig'
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.expand_path
	libdir = basedir + "lib"
	extdir = libdir + Config::CONFIG['sitearch']

	puts ">>> Adding #{libdir} to load path..."
	$LOAD_PATH.unshift( libdir.to_s )

	puts ">>> Adding #{extdir} to load path..."
	$LOAD_PATH.unshift( extdir.to_s )
}

BASEDIR = Pathname.new( __FILE__ ).dirname.parent
DATADIR = BASEDIR + 'spec/data/feedparser-tests-4.1/tests'

require 'rubygems'
require 'redleaf'
require 'pathname'
require 'redleaf/parser/rsstagsoup'
require 'logger'

Redleaf.logger.level = Logger::DEBUG

parser = Redleaf::RSSTagSoupParser.new

rssdir = Pathname.new( 'spec/data/feedparser-tests-4.1/tests/wellformed/rss' )

Pathname.glob( rssdir + '*.xml' ).each do |file|
	unless file.file?
		$stderr.puts "  skipping #{file}"
		next
	end
	
	$stderr.puts "Parsing document: #{file}:",
		file.read

	begin
		graph = parser.parse( file.read, 'http://example.org/' )
		PP.pp( graph, $stdout )
	rescue => err
		$stderr.puts "Couldn't parse it (%p)" % [ err ]
	end
end

