#!/usr/bin/env ruby

require 'rubygems'
require 'xml/libxml'
require 'logger'
require 'erb'


class SpecGenerator

	### Create a new SpecGenerator that will generate specs from the given
	### +manifest+ file (e.g., the one at 
	### http://www.w3.org/2000/10/rdf-tests/rdfcore/Manifest.rdf)
	def initialize( manifest )
		@doc = XML::Document.file( manifest.to_s )
		@root = @doc.root
		@logger = Logger.new( $stderr )
		@logger.level = Logger::ERROR
	end


	### Generate an RSpec spec file by combining the specified +template+ with the examples 
	### added to a yielded array.
	def write_specfile( template, outfile )
		template = ERB.new( template.read, 0, '<>' )
		examples = yield( [] )

		examples.flatten!
		examples.compact!

		outfile.open( File::CREAT|File::WRONLY|File::TRUNC ) do |fh|
			# $stderr.puts "Examples are: %p" % [ examples ]
			fh.print( template.result(binding()) )
		end
	end


	### Generate specs for the "Positive Parser Tests", limited to the ones marked
	### as 'APPROVED' unless +approved_only+ is +false+.
	def find_positive_parser_tests( approved_only=true )
		tests = []

		@root.find( '//test:PositiveParserTest' ).each do |node|
			test = PositiveParserTest.from_xml_node( node )
			tests << test unless approved_only && !test.approved?
		end

		return tests.flatten.compact
	end


	### Generate specs for the "Negative Parser Tests", limited to the ones marked
	### as 'APPROVED' unless +approved_only+ is +false+.
	def find_negative_parser_tests( approved_only=true )
		tests = []

		@root.find( '//test:NegativeParserTest' ).each do |node|
			test = NegativeParserTest.from_xml_node( node )
			tests << test unless approved_only && !test.approved?
		end

		return tests.flatten.compact
	end


	### Generate specs for the "Positive Entailment Tests", limited to the ones marked
	### as 'APPROVED' unless +approved_only+ is +false+.
	def find_positive_entailment_tests( approved_only=true )
		tests = []

		@root.find( '//test:PositiveEntailmentTest' ).each do |node|
			test = PositiveEntailmentTest.from_xml_node( node )
			tests << test unless approved_only && !test.approved?
		end

		return tests.flatten.compact
	end

	### Generate specs for the "Negative Entailment Tests", limited to the ones marked
	### as 'APPROVED' unless +approved_only+ is +false+.
	def find_negative_entailment_tests( approved_only=true )
		tests = []

		@root.find( '//test:NegativeEntailmentTest' ).each do |node|
			test = NegativeEntailmentTest.from_xml_node( node )
			tests << test unless approved_only && !test.approved?
		end

		return tests.flatten.compact
	end


	### Generate specs for the "Positive Parser Tests", limited to the ones marked
	### as 'APPROVED' unless +approved_only+ is +false+.
	def find_miscellaneous_tests( approved_only=true )
		tests = []

		@root.find( '//test:MiscellaneousTest' ).each do |node|
			test = MiscellaneousTest.from_xml_node( node )
			tests << test unless approved_only && !test.approved?
		end

		return tests.flatten.compact
	end


	### A base class for generating specifications out of a W3C test
	class W3CTest

		### Create a new ParserTest from the given XML::Node object.
		def self::from_xml_node( node, *constructor_args )
			id          = node['about'][%r{/rdfcore/(.*)$}, 1]
			status      = node.find_first( 'test:status' ).content

			# Optional elements
			issue       = nil
			description = nil
			approval    = nil

			if descnode = node.find_first( 'test:description' )
				description = descnode.content
			else
				description = "(No description: #{id})"
			end

			if issuenode = node.find_first( 'test:issue' )
				issue = issuenode['resource']
			end

			if approvalnode = node.find_first( 'test:approval' )
				approval = approvalnode['resource']
			end

			return self.new( id, status, approval, description, issue, *constructor_args )
		rescue => err
			$stderr.puts "Error while parsing a %s from %s" % [ self.name, node ]
			raise
		end


		### Extract the relative pathname of the premise or conclusion document from the specified
		### +node+ an (XML::Node object for the premiseDocument or conclusionDocument element)
		def self::extract_document( node )

			# "False-Document"
			if doc = node.find_first( 'test:False-Document' )
				return false

			# N-Triples document
			elsif doc = node.find_first( 'test:NT-Document' )
				return doc['about'][%r{/rdfcore/(.*)$}, 1]

			# RDF/XML document
			elsif doc = node.find_first( 'test:RDF-XML-Document' )
				return doc['about'][%r{/rdfcore/(.*)$}, 1]

			else
				raise "Unknown document type:\n" + node.to_s
			end
		end


		#################################################################
		###	I N S T A N C E   M E T H O D S
		#################################################################

		### Create a new W3CTest
		def initialize( id, status, approval, description, issue )
			@id          = id
			@status      = status

			@approval    = approval
			@description = description
			@issue       = issue

			@negative    = false
		end


		######
		public
		######

		attr_reader :id, :status, :approval, :description, :issue


		### Returns +true+ if the test is a test for a failure case.
		def is_negative_test?
			return @negative
		end


		### Returns +true+ if the test is an approved one.
		def approved?
			self.status == 'APPROVED' ? true : false
		end


		### Return the test description munged into a format suitable for use as a spec name.
		def testname
			self.description.gsub( /\s+/, ' ' ).strip
		end

	end # class W3CTest


	### Abstract base class for W3C parser tests
	class ParserTest < W3CTest

		### Create a new parser test
		def initialize( id, status, approval, description, issue, input_doc, output_doc )
			super( id, status, approval, description, issue )

			@input_doc   = input_doc
			@output_doc  = output_doc
		end

		######
		public
		######

		attr_reader :input_doc, :output_doc

	end # class SpecGenerator::ParserTest


	# Positive parser test class
	# Encapsulates a test in the manifest like:
	#  <test:PositiveParserTest rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/xmlbase/Manifest.rdf#test011">
	#     <test:issue rdf:resource="http://www.w3.org/2000/03/rdf-tracking/#rdfms-xml-base"/>
	#     <test:status>APPROVED</test:status>
	#     <test:approval rdf:resource="http://lists.w3.org/Archives/Public/w3c-rdfcore-wg/2002Mar/0235.html"/>
	#     <test:description>if we have a description, fill it in here</test:description>
	#  
	#     <test:inputDocument>
	#        <test:RDF-XML-Document rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/xmlbase/test011.rdf"/>
	#     </test:inputDocument>
	#  
	#     <test:outputDocument>
	#        <test:NT-Document rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/xmlbase/test011.nt"/>
	#     </test:outputDocument>
	#  
	#  </test:PositiveParserTest>
	class PositiveParserTest < ParserTest
		### Create a new PositiveParserTest from the given XML::Node object.
		def self::from_xml_node( node )
			input_doc   = self.extract_document( node.find_first('test:inputDocument') )
			output_doc  = self.extract_document( node.find_first('test:outputDocument') )

			return super( node, input_doc, output_doc )
		end
	end


	# Negative parser test class
	# Encapsulates a test in the manifest like:
    #   <test:NegativeParserTest rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/rdf-containers-syntax-vs-schema/Manifest.rdf#error001">
    #      <test:issue rdf:resource="http://www.w3.org/2000/03/rdf-tracking/#rdf-containers-syntax-vs-schema" />
    #      <test:status>APPROVED</test:status>
    #      <test:approval rdf:resource="http://lists.w3.org/Archives/Public/w3c-rdfcore-wg/2001Jul/0000.html" />
    #      <!-- <test:discussion rdf:resource="pointer to archived email or other discussion" /> -->
    #      <!-- <test:description>
    #       -if we have a description, fill it in here -
    #      </test:description> -->
    #   
    #      <test:inputDocument>
    #         <test:RDF-XML-Document rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/rdf-containers-syntax-vs-schema/error001.rdf" />
    #      </test:inputDocument>
    #   
    #   </test:NegativeParserTest>
	class NegativeParserTest < ParserTest

		### Create a new NegativeParserTest from the given XML::Node object.
		def self::from_xml_node( node )
			input_doc   = node.find_first( 'test:inputDocument/test:RDF-XML-Document' )['about'][%r{/rdfcore/(.*)$}, 1]
			return super( node, input_doc, nil )
		end


		### Create a new negative parser test
		def initialize( *args )
			super
			@negative    = true
		end

	end # class NegativeParserTest


	# Base class for entailment tests
	class EntailmentTest < W3CTest

		### Parse a new object from the specified document +node+ (a XML::Node object)
		def self::from_xml_node( node )
			premise_doc    = self.extract_document( node.find_first('test:premiseDocument') )
			conclusion_doc = self.extract_document( node.find_first('test:conclusionDocument') )

			rules = []
			node.find( 'test:entailmentRules' ).each do |rulenode|
				rules << rulenode['resource']
			end

			return super( node, premise_doc, conclusion_doc, rules )
		end


		### Create a new entailment test
		def initialize( id, status, approval, description, issue, premise_doc, conclusion_doc, rules )
			super( id, status, approval, description, issue )

			@premise_doc    = premise_doc
			@conclusion_doc = conclusion_doc
			@rules          = rules
		end


		######
		public
		######

		attr_reader :premise_doc, :conclusion_doc

	end # EntailmentTest


	# Positive entailment test
	# Encapsulates a test in the manifest like:
    #   <test:PositiveEntailmentTest rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/datatypes/Manifest.rdf#non-well-formed-literal-1">
    #   
    #      <test:status>APPROVED</test:status>
    #      <test:approval rdf:resource="http://lists.w3.org/Archives/Public/w3c-rdfcore-wg/2002Nov/0611.html" />
    #      <test:description>
    #        Without datatype knowledge, a 'badly-formed' datatyped literal cannot be detected.
    #      </test:description>
    #   
    #      <test:entailmentRules rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#" />
    #      <test:entailmentRules rdf:resource="http://www.w3.org/2000/01/rdf-schema#" />
    #   
    #      <test:premiseDocument>
    #         <test:NT-Document rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/datatypes/test002.nt" />
    #      </test:premiseDocument>
    #   
    #      <test:conclusionDocument>
    #         <test:NT-Document rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/datatypes/test002.nt" />
    #      </test:conclusionDocument>
    #   
    #   </test:PositiveEntailmentTest>
	class PositiveEntailmentTest < EntailmentTest
	end # class PositiveEntailmentTest


	# Negative entailment test
	# Encapsulates a test in the manifest like:
    #   <test:NegativeEntailmentTest rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/datatypes/Manifest.rdf#test009">
    #   
    #      <test:status>APPROVED</test:status>
    #      <test:approval rdf:resource="http://lists.w3.org/Archives/Public/w3c-rdfcore-wg/2002Oct/0131.html" />
    #      <test:description>
    #        From decisions listed in 
    #        http://lists.w3.org/Archives/Public/w3c-rdfcore-wg/2002Oct/0098.html
    #      </test:description>
    #   
    #       <test:entailmentRules rdf:resource="http://www.w3.org/2000/10/rdf-tests/rdfcore/testSchema#simpleEntailment" />
    #   
    #      <test:premiseDocument>
    #         <test:NT-Document rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/datatypes/test009a.nt" />
    #      </test:premiseDocument>
    #   
    #      <test:conclusionDocument>
    #         <test:NT-Document rdf:about="http://www.w3.org/2000/10/rdf-tests/rdfcore/datatypes/test009b.nt" />
    #      </test:conclusionDocument>
    #   
    #   </test:NegativeEntailmentTest>
	class NegativeEntailmentTest < EntailmentTest

		### Create a new NegativeEntailmentTest
		def initialize( *args )
			super
			@negative = true
		end

	end # class NegativeEntailmentTest


	class MiscellaneousTest < W3CTest
	end # MiscellaneousTest


end


