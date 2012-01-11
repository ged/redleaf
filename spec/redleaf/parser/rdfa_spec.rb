#!/usr/bin/env ruby

BEGIN {
	require 'rbconfig'
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent.parent

	libdir = basedir + "lib"
	extdir = libdir + Config::CONFIG['sitearch']

	$LOAD_PATH.unshift( basedir ) unless $LOAD_PATH.include?( basedir )
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

require 'rspec'

require 'spec/lib/helpers'

require 'redleaf'
require 'redleaf/parser/rdfa'
require 'redleaf/behavior/parser'


#####################################################################
###	C O N T E X T S
#####################################################################
describe Redleaf::RDFaParser do

	before( :all ) do
		setup_logging( :fatal )
	end


	before( :each ) do
		pending "no GRDDL parser type; will not test" unless 
			Redleaf::RDFaParser.is_supported?
	end


	after( :all ) do
		reset_logging()
	end


	describe "instance" do

		before( :each ) do
			setup_logging( :fatal )
			@parser = Redleaf::RDFaParser.new
		end


		it_should_behave_like "a Redleaf::Parser"


		it "requires that #parse be called with a baseuri" do
			expect {
				@parser.parse( "something" )
			}.to raise_error( ArgumentError )
		end

		it "parses a simple RDFa document (W3C 0001.xhtml)" do
			baseuri = URI( 'http://www.w3.org/2006/07/SWD/RDFa/testsuite/xhtml1-testcases/' )
			document = <<-END_XHTML
			<?xml version="1.0" encoding="UTF-8"?>
			<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">
			<html xmlns="http://www.w3.org/1999/xhtml"
			      xmlns:dc="http://purl.org/dc/elements/1.1/">
			<head>
				<title>Test 0001</title>
			</head>
			<body>
				<p>This photo was taken by <span class="author" about="photo1.jpg" property="dc:creator">Mark Birbeck</span>.</p>
			</body>
			</html>
			END_XHTML
			document.strip!

			expected_graph = Redleaf::Graph.new
			expected_graph <<
				[ baseuri + 'photo1.jpg', DC[:creator], "Mark Birbeck" ]

			results = @parser.parse( document, baseuri )

			results.should be_a( Redleaf::Graph )
			results.should === expected_graph
		end
	end


	### See also the spec generated from the W3C RDFa tests suite via the 'rdfatests' task
	### for more RDFa testing

end

# vim: set nosta noet ts=4 sw=4:

