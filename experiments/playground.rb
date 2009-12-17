#!/usr/bin/env ruby

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

DATA_URLS = [
	'http://bigasterisk.com/foaf.rdf',
	'http://danbri.livejournal.com/data/foaf',
	'http://www.w3.org/People/Berners-Lee/card.rdf',
	'http://martini.nu/mahlon-foaf.rdf',
]

# Try to require the 'thingfish' library
begin
	require 'logger'
	require 'pp'
	require 'redleaf'
	require 'redleaf/store/sqlite'
	Redleaf.logger.level = $DEBUG ? Logger::DEBUG : Logger::INFO
rescue => e
	$stderr.puts "Ack! Redleaf library failed to load: #{e.message}\n\t" +
		e.backtrace.join( "\n\t" )
end

include Redleaf::Constants::CommonNamespaces

db = Pathname.new( 'playground.db' )
store = if ( db.exist? )
	Redleaf::SQLiteStore.load( db )
else
	Redleaf::SQLiteStore.new( db )
end

graph = store.graph

if graph.empty?
	DATA_URLS.each do |url|
		puts "Loading %p" % [ url ]
		graph.load( url )
	end
end

martini = Redleaf::Namespace.new( 'http://martini.nu/mahlon-foaf.rdf' )
mahlon = martini[:me]

puts "Mahlon is: #{mahlon}"

query = <<EOF
	SELECT ?person ?project
	WHERE {
		?person foaf:currentProject ?project
	}
EOF
res = graph.query( query, :foaf => FOAF, :rdf => RDF )
res.each do |row|
	puts "%s works on %s" % [ row[:person], row[:project] ]
end

