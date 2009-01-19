#!/usr/bin/env ruby

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

require 'redleaf'
require 'redleaf/constants'
require 'redleaf/store/hashes'

XHTML_MANIFEST = 'http://www.w3.org/2006/07/SWD/RDFa/testsuite/xhtml1-testcases/rdfa-xhtml1-test-manifest.rdf'

SPEC_TEMPLATE = <<-EOF
	it "passes RDFa test %s" do
		xhtml = %p
		sparql = %p
		
		res = @parser.parse( xhtml )
		res.graph.query( sparql ).should be_true()
	end
	
EOF

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
	number = row[:test][/\d+$/]

	puts SPEC_TEMPLATE % row.values_at( :test, xhtml, sparql )
end

