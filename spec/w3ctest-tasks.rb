#!rake
#
# Rake tasks for the Redleaf W3C Test Suite
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

SPEC_GENERATOR = SPECDIR + 'spec_generator.rb'
SPEC_DATADIR = SPECDIR + 'data'
W3C_TEST_DIR = SPEC_DATADIR + 'w3ctests'
W3C_TEST_MANIFEST = W3C_TEST_DIR + 'Manifest.rdf'

TESTCASE_URL = URI.parse( 'http://www.w3.org/2000/10/rdf-tests/rdfcore/latest_All.zip' )
TESTCASE_ARCHIVE = SPEC_DATADIR + File.basename( TESTCASE_URL.path )

PARSER_SPECFILE = SPECDIR + "w3c_parser_spec.rb"
ENTAILMENT_SPECFILE = SPECDIR + "w3c_entailment_spec.rb"
MISCELLANEOUS_SPECFILE = SPECDIR + "w3c_miscellaneous_spec.rb"

SPEC_TEMPLATEDIR = SPECDIR + 'templates'
PARSER_SPEC_TEMPLATE = SPEC_TEMPLATEDIR + 'w3c_parser_spec.template'
ENTAILMENT_SPEC_TEMPLATE = SPEC_TEMPLATEDIR + 'w3c_entailment_spec.template'
MISCELLANEOUS_SPEC_TEMPLATE = SPEC_TEMPLATEDIR + 'w3c_miscellaneous_spec.template'


#####################################################################
###	T A S K S
#####################################################################

task :w3ctests => [ 'w3ctests:generate' ]

begin
	namespace :w3ctests do
		require SPEC_GENERATOR
		require 'zip/zip'

		task :default => :generate
	
		# Generate the three spec files
		desc "Generate W3C specs"
		task :generate => [ PARSER_SPECFILE, ENTAILMENT_SPECFILE, MISCELLANEOUS_SPECFILE ]

		# Need the data files from the W3C test suite -- download it and unpack it
		# if necessary
		file W3C_TEST_MANIFEST.to_s => [ W3C_TEST_DIR, TESTCASE_ARCHIVE ] do
			log "Extracting #{TESTCASE_ARCHIVE}"
			Zip::ZipFile.open( TESTCASE_ARCHIVE ) do |zipfile|
				zipfile.each do |file|
					target = W3C_TEST_DIR + file.to_s
					trace "  #{file} -> #{target}"
					target.dirname.mkpath
					file.extract( target.to_s )
				end
			end
			touch( W3C_TEST_MANIFEST, :verbose => $trace )
		end

		# The spec/data directory
		directory W3C_TEST_DIR.to_s

		# Download the latest testcase zipfile
		file TESTCASE_ARCHIVE.to_s do
			download TESTCASE_URL, TESTCASE_ARCHIVE
		end
		CLOBBER.include( TESTCASE_ARCHIVE )


		# The specfile that runs examples built from the 'parser' W3C testcases
		file PARSER_SPECFILE => [ PARSER_SPEC_TEMPLATE, W3C_TEST_MANIFEST.to_s ] do
			gen = SpecGenerator.new( W3C_TEST_MANIFEST )

			gen.write_specfile( PARSER_SPEC_TEMPLATE, PARSER_SPECFILE ) do |examples|
				examples << gen.find_positive_parser_tests
				examples << gen.find_negative_parser_tests
			end
		end
		CLOBBER.include( PARSER_SPECFILE )


		# The specfile that runs examples built from the 'entailment' W3C testcases
		file ENTAILMENT_SPECFILE => [ ENTAILMENT_SPEC_TEMPLATE, W3C_TEST_MANIFEST.to_s ] do
			gen = SpecGenerator.new( W3C_TEST_MANIFEST )

			gen.write_specfile( ENTAILMENT_SPEC_TEMPLATE, ENTAILMENT_SPECFILE ) do |examples|
				examples << gen.find_positive_entailment_tests
				examples << gen.find_negative_entailment_tests
			end
		end
		CLOBBER.include( ENTAILMENT_SPECFILE )


		# The specfile that runs examples built from the 'miscellaneous' W3C testcases
		file MISCELLANEOUS_SPECFILE => [ MISCELLANEOUS_SPEC_TEMPLATE, W3C_TEST_MANIFEST.to_s ]do
			gen = SpecGenerator.new( W3C_TEST_MANIFEST )

			gen.write_specfile( MISCELLANEOUS_SPEC_TEMPLATE, MISCELLANEOUS_SPECFILE ) do |examples|
				examples << gen.find_miscellaneous_tests
			end
		end
		CLOBBER.include( MISCELLANEOUS_SPECFILE )

	end
	
rescue LoadError => err
	namespace :w3ctests do
		task :no_w3ctests do
			fail "W3C specs not defined: %s: %s" % [ err.class.name, err.message ]
		end
		
		task :run => :no_w3ctests
		task :generate => :no_w3ctests
	end
end

