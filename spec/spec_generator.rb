#!/usr/bin/env ruby

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
		template = ERB.new( template.read, 0, '<' )
		examples = yield( [] )

		examples.flatten!.compact!
		
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
	end
	
	
	### Generate specs for the "Positive Entailment Tests", limited to the ones marked
	### as 'APPROVED' unless +approved_only+ is +false+.
	def find_positive_entailment_tests( approved_only=true )
	end
	
	### Generate specs for the "Negative Entailment Tests", limited to the ones marked
	### as 'APPROVED' unless +approved_only+ is +false+.
	def find_negative_entailment_tests( approved_only=true )
	end
	
	### Generate specs for the "Datatype-qware entailment tests", limited to the ones marked
	### as 'APPROVED' unless +approved_only+ is +false+.
	def find_datatypeaware_entailment_tests( approved_only=true )
	end
	
	### Generate specs for the "Positive Parser Tests", limited to the ones marked
	### as 'APPROVED' unless +approved_only+ is +false+.
	def find_miscellaneous_tests( approved_only=true )
	end


	### A base class for generating specifications out of a W3C test
	class W3CTest

		#################################################################
		###	I N S T A N C E   M E T H O D S
		#################################################################

		### Create a new W3CTest
		def initialize( id, status )
			@id     = id
			@status = status
		end


		######
		public
		######

		# A unique identifier for the test, generated from the unique part of the 'rdf:about'
		# attribute of the containing test element.
		attr_accessor :id
		
		# The test's status (one of 'APPROVED', 'NOT_APPROVED', 'OBSOLETE', 'OBSOLETED', 
		# or 'WITHDRAWN')
		attr_accessor :status

	end


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
	class PositiveParserTest < W3CTest
		
		### Create a new PositiveParserTest from the given XML::Node object.
		def self::from_xml_node( node )
			id          = node['about'][%r{/rdfcore/(.*)$}, 1]
			status      = node.find_first( 'test:status' ).content
			input_doc   = node.find_first( 'test:inputDocument/test:RDF-XML-Document' )['about'][%r{/rdfcore/(.*)$}, 1]
			output_doc  = node.find_first( 'test:outputDocument/test:NT-Document' )['about'][%r{/rdfcore/(.*)$}, 1]

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

			return self.new( id, status, input_doc, output_doc, approval, description, issue )
		end
		
		
		### Create a new positive parser test
		def initialize( id, status, input_doc, output_doc, approval=nil, description=nil, issue=nil )
			super( id, status )

			@input_doc   = input_doc
			@output_doc  = output_doc
			@issue       = issue
			@description = description
			@approval    = approval
		end


		######
		public
		######

		attr_reader :id, :status, :input_doc, :output_doc, :approval, :description, :issue


		### Returns +true+ if the test is an approved one.
		def approved?
			self.status == 'APPROVED' ? true : false
		end


		### Return the test description munged into a format suitable for use as a spec name.
		def testname
			self.description.gsub( /\s+/, ' ' ).strip
		end
		
	end # class SpecGenerator::PositiveParserTest
	
end


