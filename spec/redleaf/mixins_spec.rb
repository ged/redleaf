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
	require 'redleaf/mixins'
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

describe Redleaf::Loggable, " (class)" do
	before(:each) do
		@logfile = StringIO.new('')
		Redleaf.logger = Logger.new( @logfile )

		@test_class = Class.new do
			include Redleaf::Loggable

			def log_test_message( level, msg )
				self.log.send( level, msg )
			end
			
			def logdebug_test_message( msg )
				self.log_debug.debug( msg )
			end
		end
		@obj = @test_class.new
	end


	it "is able to output to the log via its #log method" do
		@obj.log_test_message( :debug, "debugging message" )
		@logfile.rewind
		@logfile.read.should =~ /debugging message/
	end

	it "is able to output to the log via its #log_debug method" do
		@obj.logdebug_test_message( "sexydrownwatch" )
		@logfile.rewind
		@logfile.read.should =~ /sexydrownwatch/
	end
end



# vim: set nosta noet ts=4 sw=4:
