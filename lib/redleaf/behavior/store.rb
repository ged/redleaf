#!/usr/bin/env ruby

require 'rspec'

require 'redleaf'
require 'redleaf/store'


# This is a shared behavior for specs which different Redleaf::Stores share in 
# common. If you're creating a Redleaf::Store implementation, you can test
# its conformity to the expectations placed on them by adding this to your spec:
# 
#    require 'redleaf/behavior/store'
#
#    describe YourStore do
#
#      it_should_behave_like "a Redleaf::Store"
#
#    end
#
# If the store has any mandatory arguments, you'll need to provide an instance
# via the instance variable `@store`, like so:
#
#     describe YourArgumentedStore do
#     
#       before( :each ) do
#         @store = described_class.new( "storename" )
#       end
#     
#      it_should_behave_like "a Redleaf::Store"
#
#     end
# 
shared_examples_for "a Redleaf::Store" do

	let( :store ) do
		@store || described_class.new
	end


	it "knows which Redland backend it uses" do
		described_class.backend.should_not be_nil()
	end

	it "knows whether it is persistent or not" do
		self.store.should respond_to( :persistent? )
	end

	it "knows what its associated graph is" do
		self.store.graph.should be_an_instance_of( Redleaf::Graph )
	end


	context "with an associated graph" do

		it "allows the association of a new Graph" do
			graph = Redleaf::Graph.new
			self.store.graph = graph
			self.store.graph.should == graph
		end

		it "copies triples from a new associated graph into the store" do
			graph = Redleaf::Graph.new
			graph.append( *TEST_FOAF_TRIPLES )
			self.store.graph = graph
			self.store.graph.statements.should have( TEST_FOAF_TRIPLES.length ).members
		end

	end
end

# vim: set nosta noet ts=4 sw=4:
