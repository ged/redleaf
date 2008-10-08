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


	describe "with no nodes" do
		before( :each ) do
			@graph = Redleaf::Graph.new
		end


		it "is equivalent to another graph with no nodes" do
			other_graph = Redleaf::Graph.new
			@graph.should == other_graph
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
			@graph.load( uri.to_s ).should == 12
		end
	end


	describe "with some nodes" do
		before( :each ) do
			@graph = Redleaf::Graph.new
			@graph.append( *TEST_FOAF_TRIPLES )
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
		
	end
end

# vim: set nosta noet ts=4 sw=4:
