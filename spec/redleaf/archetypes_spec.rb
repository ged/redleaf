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
			setup_logging( :debug )
			
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
			@extended_class.archetypes.should include( DOAP[:Project] )
		end
		
		it "can add multiple archetypes to itself" do
			@extended_class.module_eval do
				include_archetype DOAP[:Project]
				include_archetype FOAF[:Project]
			end
			@extended_class.archetypes.should have(2).members
			@extended_class.archetypes.should include( DOAP[:Project], FOAF[:Project] )
		end
		
		it "can include superclasses when adding archetypes to itself" do
			pending "completion of the feature"
			@extended_class.module_eval do
				include_archetype DOAP[:Project], :follow_inheritance => true
			end
			@extended_class.archetypes.should have(2).members
			@extended_class.archetypes.should include( DOAP[:Project], FOAF[:Project] )
		end
		
		
	end
end

# vim: set nosta noet ts=4 sw=4:
