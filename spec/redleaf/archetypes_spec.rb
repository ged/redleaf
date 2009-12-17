#!/usr/bin/env ruby

BEGIN {
	require 'rbconfig'
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent

	libdir = basedir + "lib"
	extdir = libdir + Config::CONFIG['sitearch']

	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

begin
	require 'spec'
	require 'spec/lib/constants'
	require 'spec/lib/helpers'

	require 'redleaf'
	require 'redleaf/archetypes'
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

describe Redleaf::Archetypes do
	include Redleaf::SpecHelpers,
		Redleaf::Constants::CommonNamespaces

	TEST_ARCHETYPE_VOCABULARY = Redleaf::Namespace.new( 'http://purl.org/net/schemas/book/' )

	before( :all ) do
		setup_logging( :fatal )
	end


	after( :all ) do
		reset_logging()
	end


	it "adds the ::include_archetype declarative to including classes" do
		klass = Class.new do
			include Redleaf::Archetypes
		end

		klass.should respond_to( :include_archetype )
	end


	describe "-enabled class" do

		before( :each ) do
			setup_logging( :fatal )

			@extended_class = Class.new do
				include Redleaf::Archetypes, Redleaf::Constants::CommonNamespaces
			end

			Redleaf::Graph.stub!( :load )
		end

		after( :each ) do
			reset_logging()
		end


		it "can add an archetype to itself" do
			@extended_class.module_eval do
				include_archetype DOAP[:Project]
			end
			@extended_class.archetypes.keys.should include( DOAP[:Project] )
		end

		it "can add an archetype to itself as a string" do
			@extended_class.module_eval do
				include_archetype DOAP[:Project].to_s
			end
			@extended_class.archetypes.keys.should include( DOAP[:Project] )
		end

		it "can add multiple archetypes to itself" do
			@extended_class.module_eval do
				include_archetype DOAP[:Project]
				include_archetype FOAF[:Project]
			end
			@extended_class.archetypes.should have(2).members
			@extended_class.archetypes.keys.should include( DOAP[:Project], FOAF[:Project] )
		end

		it "can include superclasses when adding archetypes to itself" do
			pending "completion of the archetypes system"
			@extended_class.module_eval do
				include_archetype DOAP[:Project], :follow_inheritance => true
			end
			@extended_class.archetypes.should have(2).members
			@extended_class.archetypes.keys.should include( DOAP[:Project], FOAF[:Project] )
		end

	end


	describe Redleaf::Archetypes::MixinFactory do

		before( :each ) do
			@store = mock( "archetypes store" )
			@graph = mock( "archetypes graph" )
			Redleaf::HashesStore.stub!( :load ).and_return( @store )
			@store.stub!( :graph ).and_return( @graph )
		end

		it "fetches the vocabulary from the store if the store has it" do
		end

	end
end

# vim: set nosta noet ts=4 sw=4:
