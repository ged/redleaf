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
        [ ME,       FOAF[:phone],               URI.parse('tel:971.645.5490') ],
        [ ME,       FOAF[:mbox_sha1sum],        "8680b054d586d747a6fcb7046e9ce7cb39554404"],
        [ ME,       FOAF[:knows],               :mahlon ],
        [ :mahlon,  RDF[:type],                 FOAF[:Person] ],
        [ :mahlon,  FOAF[:mbox_sha1sum],        "fd2b68f1f42cf523276824cb93261b0de58621b6" ],
        [ :mahlon,  FOAF[:name],                "Mahlon E Smith" ],
	]

	before( :all ) do
		setup_logging( :debug )

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
		
		it ""
	end
end

# vim: set nosta noet ts=4 sw=4:
