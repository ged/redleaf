#!/usr/bin/env ruby

require 'rspec'

require 'redleaf'
require 'redleaf/queryresult'


# This is a shared behavior for specs which different Redleaf::QueryResults share in 
# common. If you're creating a Redleaf::QueryResult implementation, you can test
# its conformity to the expectations placed on them by adding this to your spec:
# 
#    require 'redleaf/behavior/queryresult'
#
#    describe YourQueryResult do
#
#      it_should_behave_like "a Redleaf::QueryResult"
#
#    end

shared_examples_for "a Redleaf::QueryResult" do

	let( :result ) do
		@result || described_class.new
	end


	it "supports Enumerable" do
		@result.should respond_to( :each )
	end

	it "can return an XML representation of itself" do
		@result.to_xml.should =~ %r{<\?xml.version=\"1.0\".*}mx
	end

	it "can return a JSON representation of itself" do
		begin
			require 'json'
		rescue LoadError
			pending "local installation of the 'ruby-json' library"
		else
			JSON.parse( @result.to_json ).should be_an_instance_of( Hash )
		end
	end

end


# vim: set nosta noet ts=4 sw=4:
