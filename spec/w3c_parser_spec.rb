#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent

	libdir = basedir + "lib"

	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
}

begin
	require 'spec/runner'
	require 'redleaf/parser'
rescue LoadError
	unless Object.const_defined?( :Gem )
		require 'rubygems'
		retry
	end
	raise
end



#####################################################################
###	C O N T E X T S
#####################################################################
describe Redleaf::Parser do

	BASE_URI = 'http://www.w3.org/2000/10/rdf-tests/rdfcore/testSchema#'

	before( :each ) do
		@rdfxml_parser = Redland::Parser.new
		@ntriples_parser = Redland::Parser.new( 'ntriples', '' )
		
		@specdir = Pathname.new( __FILE__ ).expand_path.dirname.relative_path_from( Pathname.getwd )
		@datadir = @specdir + 'data'
	end




	# (No description: amp-in-url/Manifest.rdf#test001)

	it "passes the W3C test 'amp-in-url/Manifest.rdf#test001'" do
 		input = @datadir + 'amp-in-url/test001.rdf'
		expected = @datadir + 'amp-in-url/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# A simple datatype production; a language+datatype production. Simply duplicate the

	# constructs under http://www.w3.org/2000/10/rdf-tests/rdfcore/ntriples/test.nt

	# 

	it "passes the W3C test 'datatypes/Manifest.rdf#test001'" do
 		input = @datadir + 'datatypes/test001.rdf'
		expected = @datadir + 'datatypes/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# A parser is not required to know about well-formed datatyped literals.

	# 

	it "passes the W3C test 'datatypes/Manifest.rdf#test002'" do
 		input = @datadir + 'datatypes/test002.rdf'
		expected = @datadir + 'datatypes/test002.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# Does the treatment of literals conform to charmod ?

	# Test for success of legal Normal Form C literal

	# 

	it "passes the W3C test 'rdf-charmod-literals/Manifest.rdf#test001'" do
 		input = @datadir + 'rdf-charmod-literals/test001.rdf'
		expected = @datadir + 'rdf-charmod-literals/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# A uriref is allowed to match non-US ASCII forms

	# conforming to Unicode Normal Form C.

	# No escaping algorithm is applied.

	# 

	it "passes the W3C test 'rdf-charmod-uris/Manifest.rdf#test001'" do
 		input = @datadir + 'rdf-charmod-uris/test001.rdf'
		expected = @datadir + 'rdf-charmod-uris/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# A uriref which already has % escaping is permitted.

	# No unescaping algorithm is applied.

	# 

	it "passes the W3C test 'rdf-charmod-uris/Manifest.rdf#test002'" do
 		input = @datadir + 'rdf-charmod-uris/test002.rdf'
		expected = @datadir + 'rdf-charmod-uris/test002.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-containers-syntax-vs-schema/Manifest.rdf#test001)

	it "passes the W3C test 'rdf-containers-syntax-vs-schema/Manifest.rdf#test001'" do
 		input = @datadir + 'rdf-containers-syntax-vs-schema/test001.rdf'
		expected = @datadir + 'rdf-containers-syntax-vs-schema/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-containers-syntax-vs-schema/Manifest.rdf#test002)

	it "passes the W3C test 'rdf-containers-syntax-vs-schema/Manifest.rdf#test002'" do
 		input = @datadir + 'rdf-containers-syntax-vs-schema/test002.rdf'
		expected = @datadir + 'rdf-containers-syntax-vs-schema/test002.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-containers-syntax-vs-schema/Manifest.rdf#test003)

	it "passes the W3C test 'rdf-containers-syntax-vs-schema/Manifest.rdf#test003'" do
 		input = @datadir + 'rdf-containers-syntax-vs-schema/test003.rdf'
		expected = @datadir + 'rdf-containers-syntax-vs-schema/test003.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-containers-syntax-vs-schema/Manifest.rdf#test004)

	it "passes the W3C test 'rdf-containers-syntax-vs-schema/Manifest.rdf#test004'" do
 		input = @datadir + 'rdf-containers-syntax-vs-schema/test004.rdf'
		expected = @datadir + 'rdf-containers-syntax-vs-schema/test004.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-containers-syntax-vs-schema/Manifest.rdf#test006)

	it "passes the W3C test 'rdf-containers-syntax-vs-schema/Manifest.rdf#test006'" do
 		input = @datadir + 'rdf-containers-syntax-vs-schema/test006.rdf'
		expected = @datadir + 'rdf-containers-syntax-vs-schema/test006.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-containers-syntax-vs-schema/Manifest.rdf#test007)

	it "passes the W3C test 'rdf-containers-syntax-vs-schema/Manifest.rdf#test007'" do
 		input = @datadir + 'rdf-containers-syntax-vs-schema/test007.rdf'
		expected = @datadir + 'rdf-containers-syntax-vs-schema/test007.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-containers-syntax-vs-schema/Manifest.rdf#test008)

	it "passes the W3C test 'rdf-containers-syntax-vs-schema/Manifest.rdf#test008'" do
 		input = @datadir + 'rdf-containers-syntax-vs-schema/test008.rdf'
		expected = @datadir + 'rdf-containers-syntax-vs-schema/test008.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# A surrounding rdf:RDF element is no longer mandatory.

	# 

	it "passes the W3C test 'rdf-element-not-mandatory/Manifest.rdf#test001'" do
 		input = @datadir + 'rdf-element-not-mandatory/test001.rdf'
		expected = @datadir + 'rdf-element-not-mandatory/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-ns-prefix-confusion/Manifest.rdf#test0001)

	it "passes the W3C test 'rdf-ns-prefix-confusion/Manifest.rdf#test0001'" do
 		input = @datadir + 'rdf-ns-prefix-confusion/test0001.rdf'
		expected = @datadir + 'rdf-ns-prefix-confusion/test0001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-ns-prefix-confusion/Manifest.rdf#test0003)

	it "passes the W3C test 'rdf-ns-prefix-confusion/Manifest.rdf#test0003'" do
 		input = @datadir + 'rdf-ns-prefix-confusion/test0003.rdf'
		expected = @datadir + 'rdf-ns-prefix-confusion/test0003.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-ns-prefix-confusion/Manifest.rdf#test0004)

	it "passes the W3C test 'rdf-ns-prefix-confusion/Manifest.rdf#test0004'" do
 		input = @datadir + 'rdf-ns-prefix-confusion/test0004.rdf'
		expected = @datadir + 'rdf-ns-prefix-confusion/test0004.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-ns-prefix-confusion/Manifest.rdf#test0005)

	it "passes the W3C test 'rdf-ns-prefix-confusion/Manifest.rdf#test0005'" do
 		input = @datadir + 'rdf-ns-prefix-confusion/test0005.rdf'
		expected = @datadir + 'rdf-ns-prefix-confusion/test0005.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-ns-prefix-confusion/Manifest.rdf#test0006)

	it "passes the W3C test 'rdf-ns-prefix-confusion/Manifest.rdf#test0006'" do
 		input = @datadir + 'rdf-ns-prefix-confusion/test0006.rdf'
		expected = @datadir + 'rdf-ns-prefix-confusion/test0006.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-ns-prefix-confusion/Manifest.rdf#test0009)

	it "passes the W3C test 'rdf-ns-prefix-confusion/Manifest.rdf#test0009'" do
 		input = @datadir + 'rdf-ns-prefix-confusion/test0009.rdf'
		expected = @datadir + 'rdf-ns-prefix-confusion/test0009.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-ns-prefix-confusion/Manifest.rdf#test0010)

	it "passes the W3C test 'rdf-ns-prefix-confusion/Manifest.rdf#test0010'" do
 		input = @datadir + 'rdf-ns-prefix-confusion/test0010.rdf'
		expected = @datadir + 'rdf-ns-prefix-confusion/test0010.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-ns-prefix-confusion/Manifest.rdf#test0011)

	it "passes the W3C test 'rdf-ns-prefix-confusion/Manifest.rdf#test0011'" do
 		input = @datadir + 'rdf-ns-prefix-confusion/test0011.rdf'
		expected = @datadir + 'rdf-ns-prefix-confusion/test0011.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-ns-prefix-confusion/Manifest.rdf#test0012)

	it "passes the W3C test 'rdf-ns-prefix-confusion/Manifest.rdf#test0012'" do
 		input = @datadir + 'rdf-ns-prefix-confusion/test0012.rdf'
		expected = @datadir + 'rdf-ns-prefix-confusion/test0012.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-ns-prefix-confusion/Manifest.rdf#test0013)

	it "passes the W3C test 'rdf-ns-prefix-confusion/Manifest.rdf#test0013'" do
 		input = @datadir + 'rdf-ns-prefix-confusion/test0013.rdf'
		expected = @datadir + 'rdf-ns-prefix-confusion/test0013.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdf-ns-prefix-confusion/Manifest.rdf#test0014)

	it "passes the W3C test 'rdf-ns-prefix-confusion/Manifest.rdf#test0014'" do
 		input = @datadir + 'rdf-ns-prefix-confusion/test0014.rdf'
		expected = @datadir + 'rdf-ns-prefix-confusion/test0014.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-difference-between-ID-and-about/Manifest.rdf#test1)

	it "passes the W3C test 'rdfms-difference-between-ID-and-about/Manifest.rdf#test1'" do
 		input = @datadir + 'rdfms-difference-between-ID-and-about/test1.rdf'
		expected = @datadir + 'rdfms-difference-between-ID-and-about/test1.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# This test shows the treatment of non-ASCII characters

	# in the value of rdf:ID attribute.

	# 

	it "passes the W3C test 'rdfms-difference-between-ID-and-about/Manifest.rdf#test2'" do
 		input = @datadir + 'rdfms-difference-between-ID-and-about/test2.rdf'
		expected = @datadir + 'rdfms-difference-between-ID-and-about/test2.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# This test shows the treatment of non-ASCII characters

	# in the value of rdf:about attribute.

	# 

	it "passes the W3C test 'rdfms-difference-between-ID-and-about/Manifest.rdf#test3'" do
 		input = @datadir + 'rdfms-difference-between-ID-and-about/test3.rdf'
		expected = @datadir + 'rdfms-difference-between-ID-and-about/test3.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# The question posed to the RDF WG was: should an RDF document containing

	# multiple rdf:_n properties (with the same n) on an element be rejected as

	# illegal?

	# The WG decided that a parser should accept that case as legal RDF.

	# 

	it "passes the W3C test 'rdfms-duplicate-member-props/Manifest.rdf#test001'" do
 		input = @datadir + 'rdfms-duplicate-member-props/test001.rdf'
		expected = @datadir + 'rdfms-duplicate-member-props/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test001)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test001'" do
 		input = @datadir + 'rdfms-empty-property-elements/test001.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test002)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test002'" do
 		input = @datadir + 'rdfms-empty-property-elements/test002.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test002.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test003)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test003'" do
 		input = @datadir + 'rdfms-empty-property-elements/test003.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test003.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test004)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test004'" do
 		input = @datadir + 'rdfms-empty-property-elements/test004.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test004.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test005)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test005'" do
 		input = @datadir + 'rdfms-empty-property-elements/test005.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test005.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test006)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test006'" do
 		input = @datadir + 'rdfms-empty-property-elements/test006.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test006.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test007)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test007'" do
 		input = @datadir + 'rdfms-empty-property-elements/test007.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test007.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test008)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test008'" do
 		input = @datadir + 'rdfms-empty-property-elements/test008.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test008.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test009)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test009'" do
 		input = @datadir + 'rdfms-empty-property-elements/test009.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test009.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test010)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test010'" do
 		input = @datadir + 'rdfms-empty-property-elements/test010.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test010.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test011)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test011'" do
 		input = @datadir + 'rdfms-empty-property-elements/test011.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test011.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test012)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test012'" do
 		input = @datadir + 'rdfms-empty-property-elements/test012.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test012.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test013)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test013'" do
 		input = @datadir + 'rdfms-empty-property-elements/test013.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test013.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test014)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test014'" do
 		input = @datadir + 'rdfms-empty-property-elements/test014.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test014.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-empty-property-elements/Manifest.rdf#test015)

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test015'" do
 		input = @datadir + 'rdfms-empty-property-elements/test015.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test015.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# Like rdfms-empty-property-elements/test001.rdf but with a processing instruction

	# as the only content of the otherwise empty element.

	# 

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test016'" do
 		input = @datadir + 'rdfms-empty-property-elements/test016.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test016.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# Like rdfms-empty-property-elements/test001.rdf but with a comment

	# as the only content of the otherwise empty element.

	# 

	it "passes the W3C test 'rdfms-empty-property-elements/Manifest.rdf#test017'" do
 		input = @datadir + 'rdfms-empty-property-elements/test017.rdf'
		expected = @datadir + 'rdfms-empty-property-elements/test017.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-identity-anon-resources/Manifest.rdf#test001)

	it "passes the W3C test 'rdfms-identity-anon-resources/Manifest.rdf#test001'" do
 		input = @datadir + 'rdfms-identity-anon-resources/test001.rdf'
		expected = @datadir + 'rdfms-identity-anon-resources/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-identity-anon-resources/Manifest.rdf#test002)

	it "passes the W3C test 'rdfms-identity-anon-resources/Manifest.rdf#test002'" do
 		input = @datadir + 'rdfms-identity-anon-resources/test002.rdf'
		expected = @datadir + 'rdfms-identity-anon-resources/test002.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-identity-anon-resources/Manifest.rdf#test003)

	it "passes the W3C test 'rdfms-identity-anon-resources/Manifest.rdf#test003'" do
 		input = @datadir + 'rdfms-identity-anon-resources/test003.rdf'
		expected = @datadir + 'rdfms-identity-anon-resources/test003.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-identity-anon-resources/Manifest.rdf#test004)

	it "passes the W3C test 'rdfms-identity-anon-resources/Manifest.rdf#test004'" do
 		input = @datadir + 'rdfms-identity-anon-resources/test004.rdf'
		expected = @datadir + 'rdfms-identity-anon-resources/test004.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-identity-anon-resources/Manifest.rdf#test005)

	it "passes the W3C test 'rdfms-identity-anon-resources/Manifest.rdf#test005'" do
 		input = @datadir + 'rdfms-identity-anon-resources/test005.rdf'
		expected = @datadir + 'rdfms-identity-anon-resources/test005.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-not-id-and-resource-attr/Manifest.rdf#test001)

	it "passes the W3C test 'rdfms-not-id-and-resource-attr/Manifest.rdf#test001'" do
 		input = @datadir + 'rdfms-not-id-and-resource-attr/test001.rdf'
		expected = @datadir + 'rdfms-not-id-and-resource-attr/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-not-id-and-resource-attr/Manifest.rdf#test002)

	it "passes the W3C test 'rdfms-not-id-and-resource-attr/Manifest.rdf#test002'" do
 		input = @datadir + 'rdfms-not-id-and-resource-attr/test002.rdf'
		expected = @datadir + 'rdfms-not-id-and-resource-attr/test002.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-not-id-and-resource-attr/Manifest.rdf#test004)

	it "passes the W3C test 'rdfms-not-id-and-resource-attr/Manifest.rdf#test004'" do
 		input = @datadir + 'rdfms-not-id-and-resource-attr/test004.rdf'
		expected = @datadir + 'rdfms-not-id-and-resource-attr/test004.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-not-id-and-resource-attr/Manifest.rdf#test005)

	it "passes the W3C test 'rdfms-not-id-and-resource-attr/Manifest.rdf#test005'" do
 		input = @datadir + 'rdfms-not-id-and-resource-attr/test005.rdf'
		expected = @datadir + 'rdfms-not-id-and-resource-attr/test005.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-para196/Manifest.rdf#test001)

	it "passes the W3C test 'rdfms-para196/Manifest.rdf#test001'" do
 		input = @datadir + 'rdfms-para196/test001.rdf'
		expected = @datadir + 'rdfms-para196/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-001)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-001'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-001.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-002)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-002'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-002.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-002.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-003)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-003'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-003.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-003.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-004)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-004'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-004.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-004.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-005)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-005'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-005.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-005.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-006)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-006'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-006.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-006.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-007)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-007'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-007.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-007.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-008)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-008'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-008.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-008.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-009)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-009'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-009.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-009.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-010)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-010'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-010.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-010.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-011)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-011'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-011.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-011.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-012)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-012'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-012.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-012.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-013)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-013'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-013.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-013.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-014)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-014'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-014.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-014.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-015)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-015'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-015.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-015.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-016)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-016'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-016.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-016.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-017)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-017'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-017.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-017.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-018)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-018'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-018.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-018.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-019)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-019'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-019.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-019.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-020)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-020'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-020.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-020.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-021)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-021'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-021.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-021.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-022)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-022'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-022.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-022.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-023)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-023'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-023.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-023.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-024)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-024'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-024.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-024.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-025)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-025'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-025.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-025.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-026)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-026'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-026.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-026.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-027)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-027'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-027.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-027.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-028)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-028'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-028.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-028.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-029)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-029'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-029.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-029.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-030)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-030'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-030.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-030.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-031)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-031'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-031.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-031.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-032)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-032'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-032.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-032.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-033)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-033'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-033.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-033.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-034)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-034'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-034.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-034.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-035)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-035'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-035.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-035.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-036)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-036'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-036.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-036.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#test-037)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#test-037'" do
 		input = @datadir + 'rdfms-rdf-names-use/test-037.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/test-037.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#warn-001)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#warn-001'" do
 		input = @datadir + 'rdfms-rdf-names-use/warn-001.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/warn-001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#warn-002)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#warn-002'" do
 		input = @datadir + 'rdfms-rdf-names-use/warn-002.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/warn-002.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-rdf-names-use/Manifest.rdf#warn-003)

	it "passes the W3C test 'rdfms-rdf-names-use/Manifest.rdf#warn-003'" do
 		input = @datadir + 'rdfms-rdf-names-use/warn-003.rdf'
		expected = @datadir + 'rdfms-rdf-names-use/warn-003.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-reification-required/Manifest.rdf#test001)

	it "passes the W3C test 'rdfms-reification-required/Manifest.rdf#test001'" do
 		input = @datadir + 'rdfms-reification-required/test001.rdf'
		expected = @datadir + 'rdfms-reification-required/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-seq-representation/Manifest.rdf#test001)

	it "passes the W3C test 'rdfms-seq-representation/Manifest.rdf#test001'" do
 		input = @datadir + 'rdfms-seq-representation/test001.rdf'
		expected = @datadir + 'rdfms-seq-representation/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# rdf:nodeID can be used to label a blank node.

	# 

	it "passes the W3C test 'rdfms-syntax-incomplete/Manifest.rdf#test001'" do
 		input = @datadir + 'rdfms-syntax-incomplete/test001.rdf'
		expected = @datadir + 'rdfms-syntax-incomplete/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# rdf:nodeID can be used to label a blank node.

	# These have file scope and are distinct from any

	# unlabelled blank nodes.

	# 

	it "passes the W3C test 'rdfms-syntax-incomplete/Manifest.rdf#test002'" do
 		input = @datadir + 'rdfms-syntax-incomplete/test002.rdf'
		expected = @datadir + 'rdfms-syntax-incomplete/test002.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# On an rdf:Description or typed node rdf:nodeID behaves

	# similarly to an rdf:about.

	# 

	it "passes the W3C test 'rdfms-syntax-incomplete/Manifest.rdf#test003'" do
 		input = @datadir + 'rdfms-syntax-incomplete/test003.rdf'
		expected = @datadir + 'rdfms-syntax-incomplete/test003.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# On a property element rdf:nodeID behaves

	# similarly to rdf:resource.

	# 

	it "passes the W3C test 'rdfms-syntax-incomplete/Manifest.rdf#test004'" do
 		input = @datadir + 'rdfms-syntax-incomplete/test004.rdf'
		expected = @datadir + 'rdfms-syntax-incomplete/test004.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-uri-substructure/Manifest.rdf#test001)

	it "passes the W3C test 'rdfms-uri-substructure/Manifest.rdf#test001'" do
 		input = @datadir + 'rdfms-uri-substructure/test001.rdf'
		expected = @datadir + 'rdfms-uri-substructure/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-xml-literal-namespaces/Manifest.rdf#test001)

	it "passes the W3C test 'rdfms-xml-literal-namespaces/Manifest.rdf#test001'" do
 		input = @datadir + 'rdfms-xml-literal-namespaces/test001.rdf'
		expected = @datadir + 'rdfms-xml-literal-namespaces/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-xml-literal-namespaces/Manifest.rdf#test002)

	it "passes the W3C test 'rdfms-xml-literal-namespaces/Manifest.rdf#test002'" do
 		input = @datadir + 'rdfms-xml-literal-namespaces/test002.rdf'
		expected = @datadir + 'rdfms-xml-literal-namespaces/test002.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-xmllang/Manifest.rdf#test001)

	it "passes the W3C test 'rdfms-xmllang/Manifest.rdf#test001'" do
 		input = @datadir + 'rdfms-xmllang/test001.rdf'
		expected = @datadir + 'rdfms-xmllang/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-xmllang/Manifest.rdf#test002)

	it "passes the W3C test 'rdfms-xmllang/Manifest.rdf#test002'" do
 		input = @datadir + 'rdfms-xmllang/test002.rdf'
		expected = @datadir + 'rdfms-xmllang/test002.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-xmllang/Manifest.rdf#test003)

	it "passes the W3C test 'rdfms-xmllang/Manifest.rdf#test003'" do
 		input = @datadir + 'rdfms-xmllang/test003.rdf'
		expected = @datadir + 'rdfms-xmllang/test003.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-xmllang/Manifest.rdf#test004)

	it "passes the W3C test 'rdfms-xmllang/Manifest.rdf#test004'" do
 		input = @datadir + 'rdfms-xmllang/test004.rdf'
		expected = @datadir + 'rdfms-xmllang/test004.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-xmllang/Manifest.rdf#test005)

	it "passes the W3C test 'rdfms-xmllang/Manifest.rdf#test005'" do
 		input = @datadir + 'rdfms-xmllang/test005.rdf'
		expected = @datadir + 'rdfms-xmllang/test005.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfms-xmllang/Manifest.rdf#test006)

	it "passes the W3C test 'rdfms-xmllang/Manifest.rdf#test006'" do
 		input = @datadir + 'rdfms-xmllang/test006.rdf'
		expected = @datadir + 'rdfms-xmllang/test006.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfs-domain-and-range/Manifest.rdf#test001)

	it "passes the W3C test 'rdfs-domain-and-range/Manifest.rdf#test001'" do
 		input = @datadir + 'rdfs-domain-and-range/test001.rdf'
		expected = @datadir + 'rdfs-domain-and-range/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: rdfs-domain-and-range/Manifest.rdf#test002)

	it "passes the W3C test 'rdfs-domain-and-range/Manifest.rdf#test002'" do
 		input = @datadir + 'rdfs-domain-and-range/test002.rdf'
		expected = @datadir + 'rdfs-domain-and-range/test002.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: unrecognised-xml-attributes/Manifest.rdf#test001)

	it "passes the W3C test 'unrecognised-xml-attributes/Manifest.rdf#test001'" do
 		input = @datadir + 'unrecognised-xml-attributes/test001.rdf'
		expected = @datadir + 'unrecognised-xml-attributes/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: unrecognised-xml-attributes/Manifest.rdf#test002)

	it "passes the W3C test 'unrecognised-xml-attributes/Manifest.rdf#test002'" do
 		input = @datadir + 'unrecognised-xml-attributes/test002.rdf'
		expected = @datadir + 'unrecognised-xml-attributes/test002.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# Demonstrating the canonicalisation of XMLLiterals.

	# 

	it "passes the W3C test 'xml-canon/Manifest.rdf#test001'" do
 		input = @datadir + 'xml-canon/test001.rdf'
		expected = @datadir + 'xml-canon/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: xmlbase/Manifest.rdf#test001)

	it "passes the W3C test 'xmlbase/Manifest.rdf#test001'" do
 		input = @datadir + 'xmlbase/test001.rdf'
		expected = @datadir + 'xmlbase/test001.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: xmlbase/Manifest.rdf#test002)

	it "passes the W3C test 'xmlbase/Manifest.rdf#test002'" do
 		input = @datadir + 'xmlbase/test002.rdf'
		expected = @datadir + 'xmlbase/test002.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: xmlbase/Manifest.rdf#test003)

	it "passes the W3C test 'xmlbase/Manifest.rdf#test003'" do
 		input = @datadir + 'xmlbase/test003.rdf'
		expected = @datadir + 'xmlbase/test003.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: xmlbase/Manifest.rdf#test004)

	it "passes the W3C test 'xmlbase/Manifest.rdf#test004'" do
 		input = @datadir + 'xmlbase/test004.rdf'
		expected = @datadir + 'xmlbase/test004.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: xmlbase/Manifest.rdf#test006)

	it "passes the W3C test 'xmlbase/Manifest.rdf#test006'" do
 		input = @datadir + 'xmlbase/test006.rdf'
		expected = @datadir + 'xmlbase/test006.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: xmlbase/Manifest.rdf#test007)

	it "passes the W3C test 'xmlbase/Manifest.rdf#test007'" do
 		input = @datadir + 'xmlbase/test007.rdf'
		expected = @datadir + 'xmlbase/test007.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: xmlbase/Manifest.rdf#test008)

	it "passes the W3C test 'xmlbase/Manifest.rdf#test008'" do
 		input = @datadir + 'xmlbase/test008.rdf'
		expected = @datadir + 'xmlbase/test008.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: xmlbase/Manifest.rdf#test009)

	it "passes the W3C test 'xmlbase/Manifest.rdf#test009'" do
 		input = @datadir + 'xmlbase/test009.rdf'
		expected = @datadir + 'xmlbase/test009.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: xmlbase/Manifest.rdf#test010)

	it "passes the W3C test 'xmlbase/Manifest.rdf#test010'" do
 		input = @datadir + 'xmlbase/test010.rdf'
		expected = @datadir + 'xmlbase/test010.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: xmlbase/Manifest.rdf#test011)

	it "passes the W3C test 'xmlbase/Manifest.rdf#test011'" do
 		input = @datadir + 'xmlbase/test011.rdf'
		expected = @datadir + 'xmlbase/test011.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# (No description: xmlbase/Manifest.rdf#test013)

	it "passes the W3C test 'xmlbase/Manifest.rdf#test013'" do
 		input = @datadir + 'xmlbase/test013.rdf'
		expected = @datadir + 'xmlbase/test013.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



	# 

	# Test output corrected to use correct base URL.

	# 

	it "passes the W3C test 'xmlbase/Manifest.rdf#test014'" do
 		input = @datadir + 'xmlbase/test014.rdf'
		expected = @datadir + 'xmlbase/test014.nt'

		input_stream = @rdfxml_parser.parse_string_as_stream( input.read, BASE_URI )
		expected_stream = @ntriples_parser.parse_string_as_stream( expected.read, BASE_URI )
		
		until expected_stream.end?
			input_stmt = input_stream.current
			expected_stmt = expected_stream.current

			input_stmt.subject.should == expected_stmt.subject
			input_stmt.predicate.should == expected_stmt.predicate
			input_stmt.object.should == expected_stmt.object
			
			input_stream.next
			expected_stream.next
		end
	end



end

# vim: set nosta noet ts=4 sw=4:
