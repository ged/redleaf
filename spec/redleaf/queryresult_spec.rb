#!/usr/bin/env ruby

BEGIN {
	require 'rbconfig'
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent

	libdir = basedir + "lib"
	extdir = libdir + Config::CONFIG['sitearch']

	$LOAD_PATH.unshift( basedir ) unless $LOAD_PATH.include?( basedir )
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

require 'rspec'

require 'spec/lib/helpers'

require 'redleaf'
require 'redleaf/queryresult'


#####################################################################
###	C O N T E X T S
#####################################################################
describe Redleaf::QueryResult do

	before( :all ) do
		setup_logging( :fatal )
	end

	after( :all ) do
		reset_logging()
	end


	it "is an abtract class" do
		expect {
			Redleaf::QueryResult.new
		}.to raise_error( NoMethodError, /new/ )
	end


	it "knows what result formatters the local installation supports" do
		res = Redleaf::QueryResult.formatters

		res.should be_an_instance_of( Hash )
		res.keys.should include( 'xml' )
	end

end

