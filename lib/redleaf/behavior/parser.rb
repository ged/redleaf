#!/usr/bin/env ruby

require 'rspec'

require 'redleaf'
require 'redleaf/parser'


# This is a shared behavior for specs which different Redleaf::Parsers share in 
# common. If you're creating a Redleaf::Parser implementation, you can test
# its conformity to the expectations placed on them by adding this to your spec:
# 
#    require 'redleaf/behavior/parser'
#
#    describe YourParser do
#
#      it_should_behave_like "a Redleaf::Parser"
#
#    end

shared_examples_for "a Redleaf::Parser" do

	let( :parser ) do
		described_class.new
	end


	it "knows which Redland backend it uses" do
		described_class.parser_type.should_not be_nil()
	end

	it "knows what an accept header for the kinds of content it accepts is" do
		parser.accept_header.should =~ %r{(?:application|text|\*)/\S+}i
	end

end


# vim: set nosta noet ts=4 sw=4:
