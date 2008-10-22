#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent
	
	libdir = basedir + "lib"
	extdir = basedir + "ext"
	
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

begin
	require 'spec/runner'
	require 'spec/lib/constants'
	require 'spec/lib/helpers'

	require 'redleaf'
	require 'redleaf/graph'
	require 'redleaf/statement'
	require 'redleaf/constants'
	require 'redleaf/namespace'
rescue LoadError
	unless Object.const_defined?( :Gem )
		require 'rubygems'
		retry
	end
	raise
end


include Redleaf::TestConstants
include Redleaf::Constants

#####################################################################
###	C O N T E X T S
#####################################################################

describe Redleaf::Graph do
	include Redleaf::SpecHelpers,
	        Redleaf::Constants::CommonNamespaces

	MY_FOAF = Redleaf::Namespace.new( 'http://deveiate.org/foaf.xml#' )
	ME = MY_FOAF[:me]

	TEST_FOAF_TRIPLES = [
        [ ME,       RDF[:type],                 FOAF[:Person] ],
        [ ME,       FOAF[:name],                "Michael Granger" ],
        [ ME,       FOAF[:givenname],           "Michael" ],
        [ ME,       FOAF[:family_name],         "Granger" ],
        [ ME,       FOAF[:homepage],            URI.parse('http://deveiate.org/') ],
        [ ME,       FOAF[:workplaceHomepage],   URI.parse('http://laika.com/') ],
        [ ME,       FOAF[:phone],               URI.parse('tel:303.555.1212') ],
        [ ME,       FOAF[:mbox_sha1sum],        "8680b054d586d747a6fcb7046e9ce7cb39554404"],
        [ ME,       FOAF[:knows],               :mahlon ],
        [ :mahlon,  RDF[:type],                 FOAF[:Person] ],
        [ :mahlon,  FOAF[:mbox_sha1sum],        "fd2b68f1f42cf523276824cb93261b0de58621b6" ],
        [ :mahlon,  FOAF[:name],                "Mahlon E Smith" ],
	]

	before( :all ) do
		setup_logging( :fatal )

		@basedir     = Pathname.new( __FILE__ ).dirname.parent.parent
		@specdir     = @basedir + 'spec'
		@specdatadir = @specdir + 'data'
	end

	after( :all ) do
		reset_logging()
	end

	it "knows what types of models the underlying Redland library supports" do
		Redleaf::Graph.model_types.should be_an_instance_of( Hash )
		Redleaf::Graph.model_types.should have_at_least(1).members
	end
	

	describe "with no nodes" do
		before( :each ) do
			@graph = Redleaf::Graph.new
		end


		it "has the same store as duplicates of itself" do
			@graph.dup.store.should equal( @graph.store )
		end


		it "assigns an anonymous bnode when given the special token :_ as a subject" do
			@graph << [ :_, FOAF[:knows], ME ]
			stmt = @graph[ nil, FOAF[:knows], ME ].first
			stmt.subject.should_not == :_
			
			# :FIXME: This is Redland's identifier pattern; not sure if I should be testing it
			# this specifically or not
			stmt.subject.to_s.should =~ /r\d+r\d+r\d+/
		end
		

		it "considers bnodes to be equivalent when testing graph equality" do
			@graph << [ :_, FOAF[:knows], ME ]
			
			other_graph = Redleaf::Graph.new
			other_graph << [ :mahlon, FOAF[:knows], ME ]
			
			@graph.should === other_graph
		end
		

		it "produces tainted duplicates if it itself is tainted" do
			@graph.taint
			@graph.dup.should be_tainted()
		end
		

		it "is equivalent to another graph with no nodes" do
			other_graph = Redleaf::Graph.new
			@graph.should === other_graph
		end
		
		it "has a default store" do
			@graph.store.should be_an_instance_of( Redleaf::DEFAULT_STORE_CLASS )
		end
		
		
		it "can have statements appended to it as Redleaf::Statements" do
			stmts = TEST_FOAF_TRIPLES.collect do |triple|
				Redleaf::Statement.new( *triple )
			end
			
			stmts.each {|stmt| @graph << stmt }
			
			@graph.statements.should have( stmts.length ).members
			@graph.statements.should include( *stmts )
		end

		it "can have statements appended to it as simple triples" do
			stmt = Redleaf::Statement.new( ME, FOAF[:knows], :mahlon )
			stmt2 = Redleaf::Statement.new( :mahlon, FOAF[:knows], ME )

			@graph <<
				[ ME, FOAF[:knows], :mahlon  ] <<
				[ :mahlon,  FOAF[:knows], ME ]
			
			@graph.statements.should have( 2 ).members
			@graph.statements.should include( stmt, stmt2 )
		end
		
		it "can load URIs that point to RDF data" do
			rdfxml_file = @specdatadir + 'mgranger-foaf.xml'
			uri = URI.parse( 'file:' + rdfxml_file )
			@graph.load( uri.to_s ).should == TEST_FOAF_TRIPLES.length
		end
	end


	describe "with some nodes" do
		before( :all ) do
			setup_logging( :fatal )
		end

		before( :each ) do
			@graph = Redleaf::Graph.new
			@graph.append( *TEST_FOAF_TRIPLES )
		end
		
		after( :each ) do
			reset_logging()
		end
		
		
		it "is not equivalent to another graph with no nodes" do
			other_graph = Redleaf::Graph.new
			@graph.should_not === other_graph
		end
		
		it "is equivalent to another graph with the same nodes" do
			other_graph = Redleaf::Graph.new
			other_graph.append( *TEST_FOAF_TRIPLES )
			
			@graph.should === other_graph
			
			# Make sure testing for equivalence doesn't alter either graph
			@graph.statements.should have(12).members
			other_graph.statements.should have(12).members
		end
		
		it "is not equivalent to another graph with all the same nodes but one" do
			other_graph = Redleaf::Graph.new
			other_graph.append( *TEST_FOAF_TRIPLES[0..-2] )
			
			@graph.should_not === other_graph
		end
		
		it "has a default store" do
			@graph.store.should be_an_instance_of( Redleaf::DEFAULT_STORE_CLASS )
		end
	
		
		it "provides a way to remove statements by passing a triple" do
			triple = [ ME, FOAF[:phone], URI.parse('tel:303.555.1212') ]

			stmts = @graph.remove( triple )

			stmts.should have(1).members
			stmts[0].should be_an_instance_of( Redleaf::Statement )
			stmts[0].subject.should == ME
			stmts[0].predicate.should == FOAF[:phone]
			stmts[0].object.should == URI.parse('tel:303.555.1212')
			
			@graph[ nil, FOAF[:phone], nil ].should be_empty()
		end
		
		it "provides a way to remove statements by passing a statement object" do
			target = Redleaf::Statement.new( ME, FOAF[:phone], URI.parse('tel:303.555.1212') )

			stmts = @graph.remove( target )

			stmts.should have(1).members
			stmts[0].should be_an_instance_of( Redleaf::Statement )
			stmts[0].subject.should == ME
			stmts[0].predicate.should == FOAF[:phone]
			stmts[0].object.should == URI.parse('tel:303.555.1212')
			
			@graph[ nil, FOAF[:phone], nil ].should be_empty()
		end

		it "uses NULL nodes in the triple passed to #remove as wildcards" do
			stmts = @graph.remove([ ME, nil, nil ])

			@graph.size.should == 3
			stmts.should have(9).members
			stmts.all? {|stmt| stmt.subject == ME }.should be_true()
			
			@graph[ ME, nil, nil ].should be_empty()
		end
		
		it "raises an error if you try to #remove anything but a statement or triple" do
			lambda {
				@graph.remove( :glar )
			}.should raise_error( ArgumentError, /can't convert a Symbol to a statement/i )
			lambda {
				@graph.remove( @graph )
			}.should raise_error( ArgumentError, /can't convert a Redleaf::Graph to a statement/i )
		end
		
		it "can find statements which contain nodes that match specified ones" do
			stmts = @graph[ ME, nil, nil ]
			
			stmts.should have(9).members
			stmts.all? {|stmt| stmt.subject == ME }.should be_true()
		end
		
		it "can iterate over its statements" do
			subjects = @graph.collect {|stmt| stmt.subject.to_s }
			subjects.should have( TEST_FOAF_TRIPLES.length ).members
			subjects.uniq.should have(2).members
		end
		
		it "knows it includes a statement which has been added to it" do
			stmt = Redleaf::Statement.new( *TEST_FOAF_TRIPLES.first )
			@graph.should include( stmt )
		end
		
		it "knows it includes a valid triple which has been added to it" do
			@graph.should include( TEST_FOAF_TRIPLES.first )
		end
		
		it "knows it doesn't include a statement which hasn't been added to it" do
			stmt = Redleaf::Statement.new( :grimlok, FOAF[:knows], :skeletor )
			@graph.should_not include( stmt )
		end
	end

	describe "query interface" do
		before( :each ) do
			@graph = Redleaf::Graph.new
		end

		it "can be queried with SPARQL" do
			@graph <<
				[ :_a, RDF[:type], FOAF[:Person] ] <<
				[ :_a, FOAF[:name], "Alice" ]
			
			sparql = %{
				PREFIX :rdf <#{RDF}> 
				PREFIX :foaf <#{FOAF}>
				SELECT ?name
				WHERE
				{
					?person rdf:type foaf:Person;
					?person foaf:name ?name
				}
			}
			
			res = @graph.query( sparql )
			res.should be_an_instance_of( Redleaf::QueryResult )
			res.bindings.should == [:name]
		end
	end
end

# vim: set nosta noet ts=4 sw=4:
