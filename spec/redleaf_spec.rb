#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent
	
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

describe Redleaf do
	include Redleaf::SpecHelpers

	before( :all ) do
		reset_logging()
	end

	it "should know if its default logger is replaced" do
		Redleaf.reset_logger
		Redleaf.should be_using_default_logger
		Redleaf.logger = Logger.new( $stderr )
		Redleaf.should_not be_using_default_logger
	end


	it "returns a version string if asked" do
		Redleaf.version_string.should =~ /\w+ [\d.]+/
	end


	it "returns a version string with a build number if asked" do
		Redleaf.version_string(true).should =~ /\w+ [\d.]+ \(build \d+\)/
	end
	
	
	it "can convert a Ruby String into its equivalent literal string" do
		Redleaf.make_literal_string( "foo" ).should == 'foo'
	end
	
	it "can convert a Ruby String with a language tag into its equivalent literal string" do
		str = "foo"
		str.extend( Redleaf::StringExtensions )
		str.lang = 'de'
		Redleaf.make_literal_string( str ).should == 'foo'
	end
	

	describe " logging subsystem" do
		before(:each) do
			Redleaf.reset_logger
		end

		after(:each) do
			Redleaf.reset_logger
		end
	
	
		it "has the default logger instance after being reset" do
			Redleaf.logger.should equal( Redleaf.default_logger )
		end

		it "has the default log formatter instance after being reset" do
			Redleaf.logger.formatter.should equal( Redleaf.default_log_formatter )
		end
	
	end


	describe " logging subsystem with new defaults" do
		before( :all ) do
			@original_logger = Redleaf.default_logger
			@original_log_formatter = Redleaf.default_log_formatter
		end

		after( :all ) do
			Redleaf.default_logger = @original_logger
			Redleaf.default_log_formatter = @original_log_formatter
		end


		it "uses the new defaults when the logging subsystem is reset" do
			logger = mock( "dummy logger", :null_object => true )
			formatter = mock( "dummy logger" )
			
			Redleaf.default_logger = logger
			Redleaf.default_log_formatter = formatter

			logger.should_receive( :formatter= ).with( formatter )

			Redleaf.reset_logger
			Redleaf.logger.should equal( logger )
		end
		
	end

end

# vim: set nosta noet ts=4 sw=4:
