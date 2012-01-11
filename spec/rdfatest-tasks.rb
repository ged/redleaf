#!rake
#
# Rake tasks for the Redleaf RDFA Test Suite
#
# Copyright (c) 2008 The FaerieMUD Consortium
#
# Authors:
#  * Michael Granger <ged@FaerieMUD.org>
#


require 'rake'
require 'rake/clean'
require 'uri'
require 'pathname'

RDFA_TEST_DATADIR  = SPEC_DATADIR + 'rdfatests'
RDFA_TEST_DATAFILE = RDFA_TEST_DATADIR + '1001.xhtml'

RDFA_TEST_MANIFEST = SPEC_DATADIR + 'rdfa-xhtml1-test-manifest.rdf'
RDFA_TEST_MANIFEST_URI = 
	URI('http://www.w3.org/2006/07/SWD/RDFa/testsuite/xhtml1-testcases/rdfa-xhtml1-test-manifest.rdf')

RDFA_SPECFILE = SPECDIR + "w3c_rdfa_spec.rb"

RDFA_SPEC_TEMPLATE = SPEC_TEMPLATEDIR + 'w3c_rdfa_spec.template'

# The tests that cause Redland problems -- adding the test number to this
# causes them to be marked as 'pending'
PENDING_TESTS = {
	113 => "elimination of an abort() in libraptor's RDFalib (raptor_librdfa.c:100)",
}


#####################################################################
###	H E L P E R S
#####################################################################

### Search the specified 
def find_approved_tests( manifest )
	require 'redleaf'
	require 'redleaf/constants'
	require 'redleaf/graph'

	dc = Redleaf::Constants::CommonNamespaces::DC
	testns = Redleaf::Namespace.new( 'http://www.w3.org/2006/03/test-description#' )

	graph = Redleaf::Graph.new
	graph.load("file:" + manifest ) or fail "couldn't load RDFa test suite manifest"

	sparql = %{
		SELECT ?test ?title ?input ?result ?purpose
		WHERE {
			?test test:reviewStatus test:approved ;
			      dc:title ?title ;
			      test:purpose ?purpose ;
			      test:informationResourceInput ?input ;
			      test:informationResourceResults ?result .
		}
	}

	log "Fetching data for approved tests"
	return graph.query( sparql, :test => testns, :dc => dc ).rows
end


### Fetch the RDFa test suite manifest
def fetch_rdfa_testdata( manifest, datadir )
	find_approved_tests( manifest ).each do |row|
		input_uri = row[:input]
		input_file = datadir + Pathname( input_uri.path ).basename
		result_uri = row[:result]
		result_file = datadir + Pathname( result_uri.path ).basename

		if !input_file.exist?
			download input_uri, input_file
			trace "  sleeping for politeness..."
			# sleep 1
		else
			trace "Reusing existing %s" % [ input_file ]
		end

		if !result_file.exist?
			download result_uri, result_file
			trace "  sleeping for politeness..."
			# sleep 1
		else
			trace "Reusing existing %s" % [ result_file ]
		end
	end

end


### Generate an RSpec spec file by combining the specified +template+ 
### with the specified binding().
def write_specfile( examples, template, outfile )
	log "Writing %d examples to %s using template %s" % [ examples.length, outfile, template ]
	template = ERB.new( template.read, 0, '<>' )

	require 'text/format'
	formatter = Text::Format.new( :first_indent => 0, :columns => 94 )
	examples.each do |example|
		comment = formatter.format( example[:purpose].strip )
		trace "Comment is: %p" % [ comment ]
		example[:comment] = comment.gsub( /^/m, "\t# " )

		example[:number] = example[:input].path[/(\d+)\.xhtml$/, 1].to_i
		example[:pending] = PENDING_TESTS[ example[:number] ]
	end

	outfile.open( File::CREAT|File::WRONLY|File::TRUNC ) do |fh|
		fh.print( template.result(binding()) )
	end
end



#####################################################################
###	T A S K S
#####################################################################

desc "Generate specs for the W3C RDFa test suite"
task :rdfatests => [ 'rdfatests:generate' ]

begin
	namespace :rdfatests do
		task :default => :generate

		desc "Generate W3C RDFa test suite spec"
		task :generate => RDFA_SPECFILE

		# Download the RDFa test manifest file to #{RDFA_TEST_MANIFEST}"
		file RDFA_TEST_MANIFEST do
			download RDFA_TEST_MANIFEST_URI, RDFA_TEST_MANIFEST
		end
		CLOBBER.include( RDFA_TEST_MANIFEST.to_s )

		directory RDFA_TEST_DATADIR.to_s
		CLOBBER.include( RDFA_TEST_DATADIR.to_s )

		# Download the RDFa test suite data into RDFA_TEST_DATADIR
		task RDFA_TEST_DATAFILE => [RDFA_TEST_DATADIR, RDFA_TEST_MANIFEST] do
			fetch_rdfa_testdata( RDFA_TEST_MANIFEST, RDFA_TEST_DATADIR )
		end

		# Generate the W3C XHTML1 RDFa spec file
		file RDFA_SPECFILE => [ RDFA_TEST_MANIFEST, RDFA_TEST_DATAFILE, RDFA_SPEC_TEMPLATE ] do
			examples = find_approved_tests( RDFA_TEST_MANIFEST )
			write_specfile( examples, RDFA_SPEC_TEMPLATE, RDFA_SPECFILE )
		end
		CLOBBER.include( RDFA_SPECFILE.to_s )

	end

rescue LoadError => err
	namespace :rdfatests do
		task :no_rdfatests do
			fail "RDFA specs not defined: %s: %s" % [ err.class.name, err.message ]
		end

		task :run => :no_rdfatests
		task :generate => :no_rdfatests
	end
end

