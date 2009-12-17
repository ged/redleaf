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

require 'open-uri'

require 'redleaf'
require 'redleaf/constants'
require 'redleaf/store/hashes'

XHTML_MANIFEST = 'http://www.w3.org/2006/07/SWD/RDFa/testsuite/xhtml1-testcases/rdfa-xhtml1-test-manifest.rdf'

SPEC_TEMPLATE = <<-EOF
	it "passes RDFa test %s" do
		xhtml = File.read( '%s' )
		sparql = File.read( '%s' )
		
		graph = @parser.parse( xhtml, '%s' )
		graph.query( sparql ).should be_true()
	end
	
EOF

BASEDIR = Pathname( __FILE__ ).dirname.parent
SPECDIR = BASEDIR + 'spec'
RDFA_SPECDIR = SPECDIR + 'rdfa'
RDFA_SPECDIR.mkpath

include Redleaf::Constants::CommonNamespaces
TEST = Redleaf::Namespace.new( 'http://www.w3.org/2006/03/test-description#' )

store = Redleaf::HashesStore.load( 'rdfa-testsuite' )
graph = store.graph

if graph.statements.empty?
	puts "Loading the XHTML1 test manifest"
	graph.load( XHTML_MANIFEST ) or raise "Failed to load xhtml1 test manifest."
	puts "   loaded %d triples." % [ graph.size ]
else
	puts "Graph already had %d triples; reusing." % [ graph.size ]
end

sparql = %{
	SELECT ?test ?title ?input ?result
	WHERE {
		?test test:reviewStatus test:approved ;
		      dc:title ?title ;
		      test:informationResourceInput ?input ;
		      test:informationResourceResults ?result .
	}
}

puts "Approved tests: "
graph.query( sparql, :test => TEST, :dc => DC ).each do |row|
	input_uri = row[:input]
	input_file = RDFA_SPECDIR + Pathname( input_uri.path ).basename
	result_uri = row[:result]
	result_file = RDFA_SPECDIR + Pathname( result_uri.path ).basename

	if !input_file.exist?
		$stderr.puts "Downloading %s from %s" % [ input_file, input_uri ]
		input_file.open( 'w' ) do |fh|
			io = open( input_uri )
			fh.write( io.read )
		end
		$stderr.puts "  sleeping for politeness..."
		sleep 1
	else
		$stderr.puts "Reusing existing %s" % [ input_file ]
	end
		
	if !result_file.exist?
		$stderr.puts "Downloading %s from %s" % [ result_file, result_uri ]
		result_file.open( 'w' ) do |fh|
			io = open( result_uri )
			fh.write( io.read )
		end
		$stderr.puts "  sleeping for politeness..."
		sleep 1
	else
		$stderr.puts "Reusing existing %s" % [ result_file ]
	end
		
	puts SPEC_TEMPLATE % [
		row[:test],
		input_file.relative_path_from( BASEDIR ),
		result_file.relative_path_from( BASEDIR ),
		input_uri,
	]
end

