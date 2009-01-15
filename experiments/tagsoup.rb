#!/usr/bin/env ruby

# Experimenting with the rsstagsoup parser. Requires that the test suite from
# the Universal Feed Parser (http://feedparser.googlecode.com/files/feedparser-tests-4.1.zip) 
# be unzipped  into spec/data/feedparser-tests-4.1

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.expand_path
	libdir = basedir + "lib"
	extdir = basedir + "ext"

	puts ">>> Adding #{libdir} to load path..."
	$LOAD_PATH.unshift( libdir.to_s )

	puts ">>> Adding #{extdir} to load path..."
	$LOAD_PATH.unshift( extdir.to_s )
}

BASEDIR = Pathname.new( __FILE__ ).dirname.parent
DATADIR = BASEDIR + 'spec/data/feedparser-tests-4.1/tests'

require 'rubygems'
require 'chunker'
require 'redleaf'
require 'redleaf/parser/rsstagsoup'
require 'logger'

include Chunker

Redleaf.logger.level = Logger::DEBUG

parser = Redleaf::RSSTagSoupParser.new

$stderr.puts "Parsing document: ", DATA_ATOM_1_0.read
DATA_ATOM_1_0.rewind
pp parser.parse( DATA_ATOM_1_0.read, 'http://127.0.0.1/' )

__END__

Chunker sets these in constants:

__ATOM_1_0__
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom"
      xml:base="http://example.org/"
      xml:lang="en">
  <title type="text">
    Sample Feed
  </title>
  <subtitle type="html">
    For documentation <em>only</em>
  </subtitle>
  <link rel="alternate"
        type="html"
        href="/"/>
  <link rel="self"
        type="application/atom+xml"
        href="http://www.example.org/atom10.xml"/>
  <rights type="html">
        <p>Copyright 2005, Mark Pilgrim</p><
  </rights>
  <generator uri="http://example.org/generator/"
             version="4.0">
    Sample Toolkit
  </generator>
  <id>tag:feedparser.org,2005-11-09:/docs/examples/atom10.xml</id>
  <updated>2005-11-09T11:56:34Z</updated>
  <entry>
    <title>First entry title</title>
    <link rel="alternate"
          href="/entry/3"/>
    <link rel="related"
          type="text/html"
          href="http://search.example.com/"/>
    <link rel="via"
          type="text/html"
          href="http://toby.example.com/examples/atom10"/>
    <link rel="enclosure"
          type="video/mpeg4"
          href="http://www.example.com/movie.mp4"
          length="42301"/>
    <id>tag:feedparser.org,2005-11-09:/docs/examples/atom10.xml:3</id>
    <published>2005-11-09T00:23:47Z</published>
    <updated>2005-11-09T11:56:34Z</updated>
    <author>
      <name>Mark Pilgrim</name>
      <uri>http://diveintomark.org/</uri>
      <email>mark@example.org</email>
    </author>
    <contributor>
      <name>Joe</name>
      <url>http://example.org/joe/</url>
      <email>joe@example.org</email>
    </contributor>
    <contributor>
      <name>Sam</name>
      <url>http://example.org/sam/</url>
      <email>sam@example.org</email>
    </contributor>
    <summary type="text">
      Watch out for nasty tricks
    </summary>
    <content type="xhtml"
              xml:base="http://example.org/entry/3"
              xml:lang="en-US">
      <div xmlns="http://www.w3.org/1999/xhtml">Watch out for
      <span style="background-image: url(javascript:window.location='http://example.org/')">
      nasty tricks</span></div>
    </content>
  </entry>
</feed>
